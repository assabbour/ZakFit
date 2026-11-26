import Fluent
import Foundation

final class UserSettings: Model, @unchecked Sendable {
    static let schema = "user_settings"

    @ID(custom: "user_id", generatedBy: .user)
    var id: UUID?

    @Field(key: "timezone")
    var timezone: String

    init() {}

    init(userID: UUID, timezone: String) {
        self.id = userID
        self.timezone = timezone
    }
}