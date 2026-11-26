import Fluent
import Vapor

struct SettingsController: RouteCollection {
    private struct SettingsResponse: Content {
        let timezone: String
    }

    func boot(routes: any RoutesBuilder) throws {
        routes.get("settings", use: show)
    }

    private func show(_ req: Request) async throws -> SettingsResponse {
        let userID = try await AuthController.authenticatedUserID(req)

        guard let settings = try await UserSettings.find(userID, on: req.db) else {
            throw Abort(.notFound, reason: "Paramètres du compte introuvables.")
        }

        return SettingsResponse(timezone: settings.timezone)
    }
}
