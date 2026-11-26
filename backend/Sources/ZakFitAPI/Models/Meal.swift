import Fluent
import Foundation

final class Meal: Model, @unchecked Sendable {
    static let schema = "meals"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Field(key: "nom")
    var nom: String

    @Field(key: "calories")
    var calories: Int

    @Field(key: "consumed_at")
    var consumedAt: Date

    init() {}
}