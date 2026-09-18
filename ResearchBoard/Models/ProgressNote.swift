import Foundation

struct ProgressNote: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var content: String
    var createdAt: Date

    init(id: UUID = UUID(), content: String, createdAt: Date = .now) {
        self.id = id
        self.content = content
        self.createdAt = createdAt
    }
}
