import Foundation
import Fluent
import Vapor

struct SettingsController: RouteCollection {
    private struct SettingsResponse: Content {
        let timezone: String
    }

    func boot(routes: any RoutesBuilder) throws {
        routes.get("settings", use: show)
        routes.put("settings", use: update)
    }

    private func show(_ req: Request) async throws -> SettingsResponse {
        let settings = try await loadSettings(req)

        return SettingsResponse(timezone: settings.timezone)
    }

    private struct UpdateSettingsRequest: Content {
        let timezone: String
    }

    private func update(_ req: Request) async throws -> SettingsResponse {
        let settings = try await loadSettings(req)
        let input = try req.content.decode(UpdateSettingsRequest.self)
        let timezone = input.timezone.trimmingCharacters(in: .whitespacesAndNewlines)

        guard TimeZone(identifier: timezone) != nil else {
            throw Abort(.badRequest, reason: "Fuseau horaire invalide.")
        }

        settings.timezone = timezone
        try await settings.update(on: req.db)
        return SettingsResponse(timezone: settings.timezone)
    }

    private func loadSettings(_ req: Request) async throws -> UserSettings {
        let userID = try await AuthController.authenticatedUserID(req)

        guard let settings = try await UserSettings.find(userID, on: req.db) else {
            throw Abort(.notFound, reason: "Paramètres du compte introuvables.")
        }

        return settings
    }
}
