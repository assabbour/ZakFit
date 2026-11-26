import Fluent
import Foundation
import Vapor

struct GoalController: RouteCollection {
    private struct GoalResponse: Content {
        let id: UUID
        let type: String
        let targetValue: Int
    }

    func boot(routes: any RoutesBuilder) throws {
        routes.get("goals", use: index)
    }

    private func index(_ req: Request) async throws -> [GoalResponse] {
        let userID = try await AuthController.authenticatedUserID(req)
        let goals = try await Goal.query(on: req.db)
            .filter(\.$user.$id == userID)
            .sort(\.$type, .ascending)
            .all()

        return try goals.map { goal in
            GoalResponse(
                id: try goal.requireID(),
                type: goal.type,
                targetValue: goal.targetValue
            )
        }
    }
}
