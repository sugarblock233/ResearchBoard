import SwiftUI

struct ProjectThumbnailView: View {
    let project: ResearchProject

    private var currentIndex: Int {
        project.stages.firstIndex { $0.id == project.currentStageID } ?? 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 8) {
                Text(project.name)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.tertiary)
                    .padding(.top, 3)
            }

            HStack(spacing: 6) {
                Image(systemName: project.status.symbol)
                    .font(.system(size: 10, weight: .semibold))
                Text(project.status.title)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                Spacer()
                Text(project.currentStage?.title ?? "No stage")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .lineLimit(1)
            }
            .foregroundStyle(project.status.tint)

            VStack(alignment: .leading, spacing: 7) {
                HStack(spacing: 3) {
                    ForEach(Array(project.stages.enumerated()), id: \.element.id) { index, _ in
                        Capsule()
                            .fill(segmentColor(for: index))
                            .frame(maxWidth: .infinity)
                            .frame(height: index == currentIndex ? 7 : 5)
                    }
                }
                Text(project.status == .done ? "Complete" : "Current stage")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(minHeight: 142, alignment: .top)
        .background(project.color.softFill, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(project.color.accent.opacity(0.35), lineWidth: 1)
        }
        .shadow(color: project.color.accent.opacity(0.08), radius: 14, y: 6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(project.name), \(project.status.title), current stage \(project.currentStage?.title ?? "none")")
    }

    private func segmentColor(for index: Int) -> Color {
        if project.status == .done || index < currentIndex { return project.color.accent.opacity(0.62) }
        if index == currentIndex { return project.color.accent }
        return Color.primary.opacity(0.11)
    }
}
