import SwiftUI

struct EmptyStateView: View {
    let action: () -> Void

    var body: some View {
        VStack(spacing: 22) {
            ZStack {
                Circle()
                    .fill(.thinMaterial)
                    .frame(width: 70, height: 70)
                Image(systemName: "sparkles.rectangle.stack")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            VStack(spacing: 8) {
                Text("Research Board")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                Text("Keep your research projects visible without turning them into a task manager.")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 390)
            }
            Button(action: action) {
                Label("Create First Project", systemImage: "plus")
                    .font(.system(size: 13, weight: .semibold))
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            Text("Idea  →  Survey  →  Method  →  Experiment  →  Analysis  →  Writing")
                .font(.system(size: 11, design: .rounded))
                .foregroundStyle(.tertiary)
                .padding(.top, 5)
        }
        .frame(maxWidth: .infinity, minHeight: 390)
        .padding(36)
    }
}
