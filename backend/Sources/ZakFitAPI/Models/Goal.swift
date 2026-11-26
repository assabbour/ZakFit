import Fluent
import Foundation

final class Goal: Model, @unchecked Sendable {
    static let schema = "goals"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Field(key: "type")
    var type: String

    @Field(key: "target_value")
    var targetValue: Int

    init() {}
}
