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

    private struct CreateActivityRequest: Content {
        let nom: String
        let durationMinutes: Int
        let caloriesBurned: Int?
        let performedAt: Date
    }

    private func create(_ req: Request) async throws -> Response {
        let userID = try await AuthController.authenticatedUserID(req)
        let input = try req.content.decode(CreateActivityRequest.self)
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
}
