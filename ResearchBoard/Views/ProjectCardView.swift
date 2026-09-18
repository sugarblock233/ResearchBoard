import SwiftUI

struct ProjectCardView: View {
    @EnvironmentObject private var store: ResearchStore

    let project: ResearchProject
    let startExpanded: Bool
    let allowsToggle: Bool
    @State private var isExpanded = false
    @State private var pendingStage: ResearchStage?
    @State private var isShowingProgress = false
    @State private var isShowingEditor = false
    @State private var isShowingDeleteConfirmation = false

    init(project: ResearchProject, startExpanded: Bool = false, allowsToggle: Bool = true) {
        self.project = project
        self.startExpanded = startExpanded
        self.allowsToggle = allowsToggle
        _isExpanded = State(initialValue: startExpanded)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            StageBarView(project: project) { stage in
                guard stage.id != project.currentStageID else { return }
                pendingStage = stage
            }
            .padding(.top, 18)

            questionBlock
                .padding(.top, 19)

            actionSummary
                .padding(.top, 17)

            if isExpanded {
                expandedContent
                    .padding(.top, 21)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(20)
        .researchGlassCard()
        .contentShape(Rectangle())
        .onTapGesture {
            store.selectedProjectID = project.id
            guard allowsToggle else { return }
            withAnimation(.easeInOut(duration: 0.18)) { isExpanded.toggle() }
        }
        .confirmationDialog(
            moveDialogTitle,
            isPresented: Binding(
                get: { pendingStage != nil },
                set: { if !$0 { pendingStage = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button(moveButtonTitle) {
                if let stage = pendingStage { store.changeStage(projectID: project.id, stageID: stage.id) }
                pendingStage = nil
            }
            Button("Cancel", role: .cancel) { pendingStage = nil }
        } message: {
            Text("Your current stage will change to \(pendingStage?.title ?? "this stage").")
        }
        .sheet(isPresented: $isShowingProgress) {
            AddProgressView(projectName: project.name) { content in
                store.addProgress(projectID: project.id, content: content)
            }
        }
        .sheet(isPresented: $isShowingEditor) {
            ProjectEditorView(
                mode: .edit(project),
                onSave: { store.updateProject($0) },
                onArchive: { store.archiveProject(id: project.id) },
                onDelete: { store.deleteProject(id: project.id) }
            )
        }
        .alert("Delete \"\(project.name)\"?", isPresented: $isShowingDeleteConfirmation) {
            Button("Delete", role: .destructive) { store.deleteProject(id: project.id) }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This cannot be undone from the app. A backup may still exist in the ResearchBoard backup folder.")
        }
        .contextMenu {
            Button("Edit Project", systemImage: "pencil") { isShowingEditor = true }
            Button("Add Progress", systemImage: "plus.bubble") { isShowingProgress = true }
            Divider()
            Button("Archive Project", systemImage: "archivebox") { store.archiveProject(id: project.id) }
            Button("Delete Project", systemImage: "trash", role: .destructive) { isShowingDeleteConfirmation = true }
        }
        .animation(.easeInOut(duration: 0.18), value: isExpanded)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 5) {
                Text(project.name)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .lineLimit(2)
                Text("Updated \(project.updatedAt.researchBoardRelative)")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.tertiary)
            }
            Spacer(minLength: 12)
            StatusBadgeView(status: project.status) { status in
                store.changeStatus(projectID: project.id, status: status)
            }
            Menu {
                Button("Edit Project", systemImage: "pencil") { isShowingEditor = true }
                Button("Add Progress", systemImage: "plus.bubble") { isShowingProgress = true }
                Divider()
                Button("Archive Project", systemImage: "archivebox") { store.archiveProject(id: project.id) }
                Button("Delete Project", systemImage: "trash", role: .destructive) { isShowingDeleteConfirmation = true }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.secondary)
                    .frame(width: 25, height: 25)
                    .background(Color.primary.opacity(0.055), in: Circle())
            }
            .menuStyle(.borderlessButton)
            .help("Project actions")
        }
    }

    private var questionBlock: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("QUESTION")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .tracking(0.8)
                .foregroundStyle(.secondary)
            Text(project.question.isEmpty ? "No current research question" : project.question)
                .font(.system(size: 14, weight: project.question.isEmpty ? .regular : .medium))
                .foregroundStyle(project.question.isEmpty ? .tertiary : .primary)
                .italic(project.question.isEmpty)
                .lineLimit(isExpanded ? nil : 2)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var actionSummary: some View {
        HStack(alignment: .top, spacing: 26) {
            actionColumn(label: "NOW", value: project.currentAction)
            actionColumn(label: "NEXT", value: project.nextAction)
        }
    }

    private func actionColumn(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .tracking(0.8)
                .foregroundStyle(.secondary)
            Text(value.isEmpty ? "Nothing added yet" : value)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(value.isEmpty ? .tertiary : .primary)
                .italic(value.isEmpty)
                .lineLimit(isExpanded ? nil : 2)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 18) {
            Divider()
            HStack {
                Text("RECENT PROGRESS")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .tracking(0.8)
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    isShowingProgress = true
                } label: {
                    Label("Add Progress", systemImage: "plus")
                        .font(.system(size: 12, weight: .semibold))
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            if project.notes.isEmpty {
                Text("No progress notes yet. Add only changes that move the research forward.")
                    .font(.system(size: 12))
                    .foregroundStyle(.tertiary)
            } else {
                VStack(alignment: .leading, spacing: 13) {
                    ForEach(project.notes.prefix(6)) { note in
                        HStack(alignment: .top, spacing: 11) {
                            Text(note.createdAt.researchBoardShortDate)
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)
                                .frame(width: 68, alignment: .leading)
                            Text(note.content)
                                .font(.system(size: 13))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
            HStack {
                Spacer()
                Button("Edit Project", systemImage: "pencil") { isShowingEditor = true }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
            }
        }
    }

    private var moveDialogTitle: String {
        guard let pendingStage,
              let fromIndex = project.stages.firstIndex(where: { $0.id == project.currentStageID }),
              let toIndex = project.stages.firstIndex(where: { $0.id == pendingStage.id }) else {
            return "Change current stage?"
        }
        return toIndex > fromIndex ? "Move \(project.name) to \"\(pendingStage.title)\"?" : "Move \(project.name) back to \"\(pendingStage.title)\"?"
    }

    private var moveButtonTitle: String {
        guard let pendingStage,
              let fromIndex = project.stages.firstIndex(where: { $0.id == project.currentStageID }),
              let toIndex = project.stages.firstIndex(where: { $0.id == pendingStage.id }) else { return "Move" }
        return toIndex < fromIndex ? "Move Back" : "Move"
    }
}
