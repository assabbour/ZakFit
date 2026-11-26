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
}
