import Fluent
import Foundation
import JWT
import Vapor

struct AuthController: RouteCollection {
    private struct Registration: Content {
        let nom: String
        let email: String
        let password: String
    }

    private struct Login: Content {
        let email: String
        let password: String
    }

    private struct AccessToken: JWTPayload {
        let subject: SubjectClaim
        let expiration: ExpirationClaim

        enum CodingKeys: String, CodingKey {
            case subject = "sub"
            case expiration = "exp"
        }

        func verify(using algorithm: some JWTAlgorithm) async throws {
            try expiration.verifyNotExpired()
        }
    }

    func boot(routes: any RoutesBuilder) throws {
        let auth = routes.grouped("auth")
        auth.post("register", use: register)
        auth.post("login", use: login)
    }

    private func register(_ req: Request) async throws -> HTTPStatus {
        let input = try req.content.decode(Registration.self)
        let nom = input.nom.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = input.email.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        guard !nom.isEmpty else {
            throw Abort(.badRequest, reason: "Le nom est obligatoire.")
        }

        guard email.range(
            of: #"^[^@\s]+@[^@\s]+\.[^@\s]+$"#,
            options: .regularExpression
        ) != nil else {
            throw Abort(.badRequest, reason: "Adresse e-mail invalide.")
        }

        guard input.password.count >= 8, input.password.utf8.count <= 72 else {
            throw Abort(
                .badRequest,
                reason: "Le mot de passe doit contenir au moins 8 caractères et au plus 72 octets."
            )
        }

        let passwordHash = try await req.password.async.hash(input.password)

        do {
            try await req.db.transaction { database in
                let user = User()
                user.nom = nom
                user.email = email
                user.passwordHash = passwordHash
                try await user.create(on: database)

                let settings = UserSettings(
                    userID: try user.requireID(),
                    timezone: "Europe/Paris"
                )
                try await settings.create(on: database)
            }
        } catch {
            if let databaseError = error as? any DatabaseError,
               databaseError.isConstraintFailure,
               try await User.query(on: req.db).filter(\.$email == email).first() != nil {
                throw Abort(.conflict, reason: "Cette adresse e-mail est déjà utilisée.")
            }

            throw error
        }

        return .created
    }

    private func login(_ req: Request) async throws -> [String: String] {
        let input = try req.content.decode(Login.self)
        let email = input.email.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        guard input.password.utf8.count <= 72,
              let user = try await User.query(on: req.db)
                  .filter(\.$email == email)
                  .first(),
              user.passwordHash != "COMPTE_SQL_SANS_CONNEXION",
              try await req.password.async.verify(input.password, created: user.passwordHash)
        else {
            throw Abort(.unauthorized, reason: "Adresse e-mail ou mot de passe incorrect.")
        }

        let userID = try user.requireID()
        let payload = AccessToken(
            subject: .init(value: userID.uuidString),
            expiration: .init(value: Date().addingTimeInterval(3_600))
        )

        let token = try await req.jwt.sign(payload)
        return ["token": token]
    }
}