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
        routes.post("goals", use: create)
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

    private struct GoalRequest: Content {
        let type: String
        let targetValue: Int
    }

    private func create(_ req: Request) async throws -> Response {
        let userID = try await AuthController.authenticatedUserID(req)
        let input = try req.content.decode(GoalRequest.self)

        guard input.type == "calories_consumed" || input.type == "activity_minutes" else {
            throw Abort(.badRequest, reason: "Type d’objectif invalide.")
        }

        guard (1...Int(Int32.max)).contains(input.targetValue) else {
            throw Abort(.badRequest, reason: "La cible doit être un entier strictement positif.")
        }

        let goal = Goal()
        goal.$user.id = userID
        goal.type = input.type
        goal.targetValue = input.targetValue
        try await goal.create(on: req.db)

        let response = Response(status: .created)
        try response.content.encode(GoalResponse(
            id: try goal.requireID(),
            type: goal.type,
            targetValue: goal.targetValue
        ))
        return response
    }
}
