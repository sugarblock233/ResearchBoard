import SwiftUI

struct StageBarView: View {
    let project: ResearchProject
    let onSelect: (ResearchStage) -> Void

    private var currentIndex: Int {
        project.stages.firstIndex { $0.id == project.currentStageID } ?? 0
    }

    var body: some View {
        Group {
            if project.stages.count <= 8 {
                stageContent
                    .frame(maxWidth: .infinity)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    stageContent
                        .frame(minWidth: CGFloat(project.stages.count * 92))
                }
            }
        }
    }

    private var stageContent: some View {
        HStack(spacing: 3) {
            ForEach(Array(project.stages.enumerated()), id: \.element.id) { index, stage in
                Button {
                    onSelect(stage)
                } label: {
                    VStack(alignment: .leading, spacing: 7) {
                        Text(stage.title)
                            .font(.system(size: 11, weight: index == currentIndex ? .semibold : .medium, design: .rounded))
                            .foregroundStyle(index <= currentIndex || project.status == .done ? .primary : .secondary)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(fillColor(for: index))
                            .frame(height: index == currentIndex ? 9 : 7)
                            .overlay(alignment: .trailing) {
                                if index == currentIndex && project.status != .done {
                                    Circle()
                                        .fill(.white.opacity(0.9))
                                        .frame(width: 5, height: 5)
                                        .padding(.trailing, 4)
                                }
                            }
                        if index == currentIndex && project.status != .done {
                            Text("CURRENT")
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .tracking(0.55)
                                .foregroundStyle(project.color.accent)
                        } else {
                            Color.clear.frame(height: 11)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .frame(minWidth: 84, maxWidth: .infinity)
                .accessibilityLabel("\(stage.title), \(accessibilityState(for: index)) stage")
            }
        }
        .padding(.vertical, 2)
    }

    private func fillColor(for index: Int) -> Color {
        if project.status == .done || index < currentIndex { return project.color.accent.opacity(0.72) }
        if index == currentIndex { return project.color.accent }
        return Color.primary.opacity(0.10)
    }

    private func accessibilityState(for index: Int) -> String {
        if project.status == .done || index < currentIndex { return "completed" }
        if index == currentIndex { return "current" }
        return "future"
    }
}
