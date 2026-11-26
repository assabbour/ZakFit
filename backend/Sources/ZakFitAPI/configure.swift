import Fluent
import FluentPostgresDriver
import FluentSQL
import JWT
import NIOSSL
import Vapor

func configure(_ app: Application) async throws {
    guard let secret = Environment.get("JWT_SECRET"), secret.utf8.count >= 32 else {
        throw Abort(.internalServerError, reason: "JWT_SECRET est absent ou trop court.")
    }

    await app.jwt.keys.add(hmac: HMACKey(from: secret), digestAlgorithm: .sha256)

    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:))
            ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database",
        tls: .prefer(try .init(configuration: .clientDefault))
    )), as: .psql)

    app.get("health", "database") { request async throws -> String in
        guard let sql = request.db as? any SQLDatabase else {
            throw Abort(.serviceUnavailable)
        }

        try await sql.raw("SELECT 1 FROM users LIMIT 1").run()
        return "OK"
    }

    try routes(app)
}