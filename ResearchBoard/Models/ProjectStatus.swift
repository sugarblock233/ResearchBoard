import Foundation
import SwiftUI

enum ProjectStatus: String, Codable, CaseIterable, Identifiable {
    case thinking
    case survey
    case running
    case analyzing
    case waiting
    case blocked
    case writing
    case paused
    case done

    var id: String { rawValue }

    var title: String {
        switch self {
        case .thinking: "Thinking"
        case .survey: "Survey"
        case .running: "Running"
        case .analyzing: "Analyzing"
        case .waiting: "Waiting"
        case .blocked: "Blocked"
        case .writing: "Writing"
        case .paused: "Paused"
        case .done: "Done"
        }
    }

    var symbol: String {
        switch self {
        case .thinking: "brain.head.profile"
        case .survey: "magnifyingglass"
        case .running: "flask"
        case .analyzing: "chart.xyaxis.line"
        case .waiting: "clock"
        case .blocked: "exclamationmark.triangle"
        case .writing: "square.and.pencil"
        case .paused: "pause.circle"
        case .done: "checkmark.circle"
        }
    }

    var tint: Color {
        switch self {
        case .thinking: .purple
        case .survey: .blue
        case .running: .green
        case .analyzing: .indigo
        case .waiting: .secondary
        case .blocked: .orange
        case .writing: .teal
        case .paused: .secondary
        case .done: .green
        }
    }

    var needsAttention: Bool {
        switch self {
        case .thinking, .survey, .analyzing, .blocked, .writing: true
        case .running, .waiting, .paused, .done: false
        }
    }

    var sortPriority: Int {
        switch self {
        case .thinking: 0
        case .blocked: 1
        case .survey: 2
        case .analyzing: 3
        case .writing: 4
        case .running: 5
        case .waiting: 6
        case .paused: 7
        case .done: 8
        }
    }
}
