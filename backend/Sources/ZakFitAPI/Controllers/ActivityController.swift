import Fluent
import Foundation
import Vapor

struct ActivityController: RouteCollection {
    private struct ActivityResponse: Content {
        let id: UUID
        let nom: String
        let durationMinutes: Int
        let caloriesBurned: Int?
        let performedAt: Date
    }

    func boot(routes: any RoutesBuilder) throws {
        routes.get("activities", use: index)
        routes.post("activities", use: create)
        routes.put("activities", ":id", use: update)
        routes.delete("activities", ":id", use: delete)
    }

    private func index(_ req: Request) async throws -> [ActivityResponse] {
        let userID = try await AuthController.authenticatedUserID(req)
        let activities = try await Activity.query(on: req.db)
            .filter(\.$user.$id == userID)
            .sort(\.$performedAt, .descending)
            .all()

        return try activities.map { activity in
            ActivityResponse(
                id: try activity.requireID(),
                nom: activity.nom,
                durationMinutes: activity.durationMinutes,
                caloriesBurned: activity.caloriesBurned,
                performedAt: activity.performedAt
            )
        }
    }

    private struct ActivityRequest: Content {
        let nom: String
        let durationMinutes: Int
        let caloriesBurned: Int?
        let performedAt: Date
    }

    private func create(_ req: Request) async throws -> Response {
        let userID = try await AuthController.authenticatedUserID(req)
        let input = try req.content.decode(ActivityRequest.self)
        let nom = try validatedName(for: input)

        let activity = Activity()
        activity.$user.id = userID
        activity.nom = nom
        activity.durationMinutes = input.durationMinutes
        activity.caloriesBurned = input.caloriesBurned
        activity.performedAt = input.performedAt
        try await activity.create(on: req.db)

        let response = Response(status: .created)
        try response.content.encode(ActivityResponse(
            id: try activity.requireID(),
            nom: activity.nom,
            durationMinutes: activity.durationMinutes,
            caloriesBurned: activity.caloriesBurned,
            performedAt: activity.performedAt
        ))
        return response
    }

    private func update(_ req: Request) async throws -> ActivityResponse {
        let activity = try await ownedActivity(req)
        let input = try req.content.decode(ActivityRequest.self)
        activity.nom = try validatedName(for: input)
        activity.durationMinutes = input.durationMinutes
        activity.caloriesBurned = input.caloriesBurned
        activity.performedAt = input.performedAt
        try await activity.update(on: req.db)

        return ActivityResponse(
            id: try activity.requireID(),
            nom: activity.nom,
            durationMinutes: activity.durationMinutes,
            caloriesBurned: activity.caloriesBurned,
            performedAt: activity.performedAt
        )
    }

    private func delete(_ req: Request) async throws -> HTTPStatus {
        let activity = try await ownedActivity(req)
        try await activity.delete(on: req.db)
        return .noContent
    }

    private func ownedActivity(_ req: Request) async throws -> Activity {
        let userID = try await AuthController.authenticatedUserID(req)

        guard let rawID = req.parameters.get("id"),
              let activityID = UUID(uuidString: rawID) else {
            throw Abort(.badRequest, reason: "Identifiant de l’activité invalide.")
        }

        guard let activity = try await Activity.query(on: req.db)
            .filter(\.$id == activityID)
            .filter(\.$user.$id == userID)
            .first() else {
            throw Abort(.notFound, reason: "Activité introuvable.")
        }

        return activity
    }

    private func validatedName(for input: ActivityRequest) throws -> String {
        let nom = input.nom.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !nom.isEmpty else {
            throw Abort(.badRequest, reason: "Le nom de l’activité est obligatoire.")
        }

        guard (1...Int(Int32.max)).contains(input.durationMinutes) else {
            throw Abort(.badRequest, reason: "La durée doit être un nombre positif de minutes.")
        }

        if let calories = input.caloriesBurned,
           !(0...Int(Int32.max)).contains(calories) {
            throw Abort(.badRequest, reason: "Le nombre de calories dépensées est invalide.")
        }

        return nom
    }
}
