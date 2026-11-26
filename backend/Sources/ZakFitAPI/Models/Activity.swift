import Fluent
import Foundation

final class Activity: Model, @unchecked Sendable {
    static let schema = "activities"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Field(key: "nom")
    var nom: String

    @Field(key: "duration_minutes")
    var durationMinutes: Int

    @OptionalField(key: "calories_burned")
    var caloriesBurned: Int?

    @Field(key: "performed_at")
    var performedAt: Date

    init() {}
}
