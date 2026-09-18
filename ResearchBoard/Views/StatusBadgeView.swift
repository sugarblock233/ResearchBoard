import SwiftUI

struct StatusBadgeView: View {
    let status: ProjectStatus
    let onChange: (ProjectStatus) -> Void

    var body: some View {
        Menu {
            ForEach(ProjectStatus.allCases) { option in
                Button {
                    onChange(option)
                } label: {
                    Label(option.title, systemImage: option.symbol)
                }
            }
        } label: {
            HStack(spacing: 7) {
                Image(systemName: status.symbol)
                    .font(.system(size: 12, weight: .semibold))
                Text(status.title)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(status.tint)
            .padding(.horizontal, 11)
            .padding(.vertical, 7)
            .background(status.tint.opacity(0.11), in: Capsule())
            .overlay {
                Capsule().strokeBorder(status.tint.opacity(0.18), lineWidth: 1)
            }
        }
        .menuStyle(.borderlessButton)
        .help("Change project status")
        .accessibilityLabel("Status: \(status.title)")
    }
}
