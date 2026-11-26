import Fluent
import Foundation
import Vapor

struct MealController: RouteCollection {
    private struct MealResponse: Content {
        let id: UUID
        let nom: String
        let calories: Int
        let consumedAt: Date
    }

    func boot(routes: any RoutesBuilder) throws {
        routes.get("meals", use: index)
        routes.post("meals", use: create)
        routes.put("meals", ":id", use: update)
    }

    private func index(_ req: Request) async throws -> [MealResponse] {
        let userID = try await AuthController.authenticatedUserID(req)
        let meals = try await Meal.query(on: req.db)
            .filter(\.$user.$id == userID)
            .sort(\.$consumedAt, .descending)
            .all()

        return try meals.map { meal in
            MealResponse(
                id: try meal.requireID(),
                nom: meal.nom,
                calories: meal.calories,
                consumedAt: meal.consumedAt
            )
        }
    }

    private struct MealRequest: Content {
        let nom: String
        let calories: Int
        let consumedAt: Date
    }

    private func create(_ req: Request) async throws -> Response {
        let userID = try await AuthController.authenticatedUserID(req)
        let input = try req.content.decode(MealRequest.self)
        let nom = try validatedName(for: input)

        let meal = Meal()
        meal.$user.id = userID
        meal.nom = nom
        meal.calories = input.calories
        meal.consumedAt = input.consumedAt
        try await meal.create(on: req.db)

        let response = Response(status: .created)
        try response.content.encode(MealResponse(
            id: try meal.requireID(),
            nom: meal.nom,
            calories: meal.calories,
            consumedAt: meal.consumedAt
        ))
        return response
    }

    private func update(_ req: Request) async throws -> MealResponse {
        let userID = try await AuthController.authenticatedUserID(req)

        guard let rawID = req.parameters.get("id"),
              let mealID = UUID(uuidString: rawID) else {
            throw Abort(.badRequest, reason: "Identifiant du repas invalide.")
        }

        guard let meal = try await Meal.query(on: req.db)
            .filter(\.$id == mealID)
            .filter(\.$user.$id == userID)
            .first() else {
            throw Abort(.notFound, reason: "Repas introuvable.")
        }

        let input = try req.content.decode(MealRequest.self)
        meal.nom = try validatedName(for: input)
        meal.calories = input.calories
        meal.consumedAt = input.consumedAt
        try await meal.update(on: req.db)

        return MealResponse(
            id: mealID,
            nom: meal.nom,
            calories: meal.calories,
            consumedAt: meal.consumedAt
        )
    }

    private func validatedName(for input: MealRequest) throws -> String {
        let nom = input.nom.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !nom.isEmpty else {
            throw Abort(.badRequest, reason: "Le nom du repas est obligatoire.")
        }

        guard (0...Int(Int32.max)).contains(input.calories) else {
            throw Abort(.badRequest, reason: "Le nombre de calories est invalide.")
        }
        return nom
    }
}
