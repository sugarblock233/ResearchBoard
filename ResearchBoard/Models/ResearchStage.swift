import Foundation

struct ResearchStage: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var title: String

    init(id: UUID = UUID(), title: String) {
        self.id = id
        self.title = title
    }
}
