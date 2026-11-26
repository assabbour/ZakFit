import Fluent
import Foundation
import Vapor

enum HistoryDateFilter {
    static func day(for req: Request, userID: UUID) async throws -> DateInterval? {
        struct Query: Decodable {
            let date: String?
        }

        guard let date = try req.query.decode(Query.self).date else {
            return nil
        }

        guard let settings = try await UserSettings.find(userID, on: req.db) else {
            throw Abort(.notFound, reason: "Paramètres du compte introuvables.")
        }

        guard let timezone = TimeZone(identifier: settings.timezone) else {
            throw Abort(.internalServerError, reason: "Fuseau horaire du compte invalide.")
        }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timezone

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = calendar
        formatter.timeZone = timezone
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.isLenient = false

        guard let parsedDate = formatter.date(from: date),
              formatter.string(from: parsedDate) == date,
              let day = calendar.dateInterval(of: .day, for: parsedDate) else {
            throw Abort(.badRequest, reason: "La date doit être valide et au format AAAA-MM-JJ.")
        }

        return day
    }
}
