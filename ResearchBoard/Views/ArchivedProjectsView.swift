import SwiftUI

struct ArchivedProjectsView: View {
    @EnvironmentObject private var store: ResearchStore
    @Environment(\.dismiss) private var dismiss
    @State private var projectToDelete: ResearchProject?

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            sheetHeader(title: "Archived Projects", subtitle: "Projects here are hidden from your daily board.")
            if store.archivedProjects.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "archivebox")
                        .font(.system(size: 28))
                        .foregroundStyle(.tertiary)
                    Text("No archived projects")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 180)
            } else {
                ScrollView {
                    VStack(spacing: 9) {
                        ForEach(store.archivedProjects) { project in
                            HStack(spacing: 12) {
                                Image(systemName: "archivebox")
                                    .foregroundStyle(.secondary)
                                Text(project.name)
                                    .font(.system(size: 14, weight: .medium))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Button("Restore") { store.restoreProject(id: project.id) }
                                    .buttonStyle(.bordered)
                                    .controlSize(.small)
                                Button(role: .destructive) { projectToDelete = project } label: {
                                    Image(systemName: "trash")
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                                .help("Delete permanently")
                            }
                            .padding(11)
                            .background(Color.primary.opacity(0.045), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                    }
                }
            }
            HStack {
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.cancelAction)
            }
        }
        .padding(28)
        .frame(width: 530, height: 430)
        .confirmationDialog("Delete this archived project?", isPresented: Binding(
            get: { projectToDelete != nil },
            set: { if !$0 { projectToDelete = nil } }
        ), titleVisibility: .visible) {
            Button("Delete Permanently", role: .destructive) {
                if let projectToDelete { store.deleteProject(id: projectToDelete.id) }
                projectToDelete = nil
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Delete \"\(projectToDelete?.name ?? "this project")\"? This cannot be undone from the app.")
        }
    }
}
