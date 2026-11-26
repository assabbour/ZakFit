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
        routes.put("goals", ":id", use: update)
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

        try validate(input)

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

    private func update(_ req: Request) async throws -> GoalResponse {
        let goal = try await ownedGoal(req)
        let input = try req.content.decode(GoalRequest.self)
        try validate(input)

        goal.type = input.type
        goal.targetValue = input.targetValue
        try await goal.update(on: req.db)

        return GoalResponse(
            id: try goal.requireID(),
            type: goal.type,
            targetValue: goal.targetValue
        )
    }

    private func ownedGoal(_ req: Request) async throws -> Goal {
        let userID = try await AuthController.authenticatedUserID(req)

        guard let rawID = req.parameters.get("id"),
              let goalID = UUID(uuidString: rawID) else {
            throw Abort(.badRequest, reason: "Identifiant de l’objectif invalide.")
        }

        guard let goal = try await Goal.query(on: req.db)
            .filter(\.$id == goalID)
            .filter(\.$user.$id == userID)
            .first() else {
            throw Abort(.notFound, reason: "Objectif introuvable.")
        }

        return goal
    }

    private func validate(_ input: GoalRequest) throws {
        guard input.type == "calories_consumed" || input.type == "activity_minutes" else {
            throw Abort(.badRequest, reason: "Type d’objectif invalide.")
        }

        guard (1...Int(Int32.max)).contains(input.targetValue) else {
            throw Abort(.badRequest, reason: "La cible doit être un entier strictement positif.")
        }
    }
}
