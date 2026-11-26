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
        routes.get("dashboard", "weekly", use: weekly)
    }

    private struct DailyPoint: Content {
        let date: String
        let caloriesConsumed: Int
        let activityMinutes: Int
    }

    private func show(_ req: Request) async throws -> DailyTotals {
        let (userID, calendar, sql) = try await dashboardContext(req)

        guard let day = calendar.dateInterval(of: .day, for: Date()) else {
            throw Abort(.internalServerError)
        }

        return try await totals(for: day, userID: userID, sql: sql)
    }

    private func weekly(_ req: Request) async throws -> [DailyPoint] {
        let (userID, calendar, sql) = try await dashboardContext(req)
        let today = calendar.startOfDay(for: Date())

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = "yyyy-MM-dd"

        var points: [DailyPoint] = []
        for offset in -6...0 {
            guard let date = calendar.date(byAdding: .day, value: offset, to: today),
                  let day = calendar.dateInterval(of: .day, for: date) else {
                throw Abort(.internalServerError)
            }

            let daily = try await totals(for: day, userID: userID, sql: sql)
            points.append(DailyPoint(
                date: formatter.string(from: day.start),
                caloriesConsumed: daily.caloriesConsumed,
                activityMinutes: daily.activityMinutes
            ))
        }

        return points
    }

    private func dashboardContext(
        _ req: Request
    ) async throws -> (UUID, Calendar, any SQLDatabase) {
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

        return (userID, calendar, sql)
    }

    private func totals(
        for day: DateInterval,
        userID: UUID,
        sql: any SQLDatabase
    ) async throws -> DailyTotals {
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
