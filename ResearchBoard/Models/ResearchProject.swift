import Foundation

struct ResearchProject: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var name: String
    var stages: [ResearchStage]
    var currentStageID: UUID
    var status: ProjectStatus
    var color: ProjectColor
    var question: String
    var currentAction: String
    var nextAction: String
    var notes: [ProgressNote]
    var createdAt: Date
    var updatedAt: Date
    var isArchived: Bool
    var sortOrder: Int

    private enum CodingKeys: String, CodingKey {
        case id, name, stages, currentStageID, status, color, question, currentAction, nextAction
        case notes, createdAt, updatedAt, isArchived, sortOrder
    }

    init(
        id: UUID = UUID(),
        name: String,
        stages: [ResearchStage] = ResearchProject.makeDefaultStages(),
        currentStageID: UUID? = nil,
        status: ProjectStatus = .thinking,
        color: ProjectColor = .ocean,
        question: String = "",
        currentAction: String = "",
        nextAction: String = "",
        notes: [ProgressNote] = [],
        createdAt: Date = .now,
        updatedAt: Date = .now,
        isArchived: Bool = false,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.name = name
        self.stages = stages
        self.currentStageID = currentStageID ?? stages.first?.id ?? UUID()
        self.status = status
        self.color = color
        self.question = question
        self.currentAction = currentAction
        self.nextAction = nextAction
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isArchived = isArchived
        self.sortOrder = sortOrder
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let name = try container.decode(String.self, forKey: .name)
        let stages = try container.decode([ResearchStage].self, forKey: .stages)
        let status = try container.decode(ProjectStatus.self, forKey: .status)
        let createdAt = try container.decode(Date.self, forKey: .createdAt)
        let updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        self.init(
            id: id,
            name: name,
            stages: stages,
            currentStageID: try container.decodeIfPresent(UUID.self, forKey: .currentStageID),
            status: status,
            color: try container.decodeIfPresent(ProjectColor.self, forKey: .color) ?? .ocean,
            question: try container.decodeIfPresent(String.self, forKey: .question) ?? "",
            currentAction: try container.decodeIfPresent(String.self, forKey: .currentAction) ?? "",
            nextAction: try container.decodeIfPresent(String.self, forKey: .nextAction) ?? "",
            notes: try container.decodeIfPresent([ProgressNote].self, forKey: .notes) ?? [],
            createdAt: createdAt,
            updatedAt: updatedAt,
            isArchived: try container.decodeIfPresent(Bool.self, forKey: .isArchived) ?? false,
            sortOrder: try container.decodeIfPresent(Int.self, forKey: .sortOrder) ?? status.sortPriority
        )
    }

    static func makeDefaultStages() -> [ResearchStage] {
        [
            ResearchStage(title: "Idea"),
            ResearchStage(title: "Survey"),
            ResearchStage(title: "Method"),
            ResearchStage(title: "Experiment"),
            ResearchStage(title: "Analysis"),
            ResearchStage(title: "Writing")
        ]
    }

    var currentStage: ResearchStage? {
        stages.first { $0.id == currentStageID }
    }
}

struct ResearchBoardData: Codable, Equatable {
    var schemaVersion: Int
    var projects: [ResearchProject]
}
