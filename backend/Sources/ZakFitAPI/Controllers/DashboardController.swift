import Fluent
import FluentSQL
import Foundation
import Vapor

struct DashboardController: RouteCollection {
    private struct DailyTotals: Content {
        let caloriesConsumed: Int
        let activityMinutes: Int
    }

    func boot(routes: any RoutesBuilder) throws {
        routes.get("dashboard", use: show)
    }

    private func show(_ req: Request) async throws -> DailyTotals {
        let userID = try await AuthController.authenticatedUserID(req)

        guard let settings = try await UserSettings.find(userID, on: req.db) else {
            throw Abort(.notFound, reason: "Paramètres du compte introuvables.")
        }

        guard let timezone = TimeZone(identifier: settings.timezone),
              let sql = req.db as? any SQLDatabase else {
            throw Abort(.internalServerError)
        }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timezone

        guard let day = calendar.dateInterval(of: .day, for: Date()) else {
            throw Abort(.internalServerError)
        }

        let totals = try await sql.raw("""
            SELECT
                COALESCE((
                    SELECT SUM(calories)
                    FROM meals
                    WHERE user_id = \(bind: userID)
                      AND consumed_at >= \(bind: day.start)
                      AND consumed_at < \(bind: day.end)
                ), 0) AS "caloriesConsumed",
                COALESCE((
                    SELECT SUM(duration_minutes)
                    FROM activities
                    WHERE user_id = \(bind: userID)
                      AND performed_at >= \(bind: day.start)
                      AND performed_at < \(bind: day.end)
                ), 0) AS "activityMinutes"
            """).first(decoding: DailyTotals.self)

        guard let totals else {
            throw Abort(.internalServerError)
        }

        return totals
    }
}
