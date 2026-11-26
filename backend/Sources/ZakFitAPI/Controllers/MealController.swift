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
}