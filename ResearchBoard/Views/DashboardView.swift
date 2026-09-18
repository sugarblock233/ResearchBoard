import SwiftUI
import UniformTypeIdentifiers

struct DashboardView: View {
    @EnvironmentObject private var store: ResearchStore
    @State private var isShowingNewProject = false
    @State private var isShowingArchived = false
    @State private var isShowingLoadError = false
    @State private var isShowingSaveError = false
    @State private var projectForEdit: ResearchProject?
    @State private var projectForProgress: ResearchProject?

    var body: some View {
        NavigationStack {
            ZStack {
                Color(nsColor: .windowBackgroundColor)
                    .ignoresSafeArea()
                VStack(spacing: 0) {
                    header
                    Divider()
                        .opacity(0.55)
                    boardContent
                }
            }
            .navigationDestination(for: UUID.self) { projectID in
                ProjectDetailView(projectID: projectID)
            }
            .background(Color(nsColor: .windowBackgroundColor))
        }
        .frame(minWidth: 620, minHeight: 430)
        .sheet(isPresented: $isShowingNewProject) {
            ProjectEditorView(mode: .new) { project in
                store.addProject(project)
            }
        }
        .sheet(isPresented: $isShowingArchived) {
            ArchivedProjectsView()
                .environmentObject(store)
        }
        .sheet(item: $projectForEdit) { project in
            ProjectEditorView(
                mode: .edit(project),
                onSave: { store.updateProject($0) },
                onArchive: { store.archiveProject(id: project.id) },
                onDelete: { store.deleteProject(id: project.id) }
            )
        }
        .sheet(item: $projectForProgress) { project in
            AddProgressView(projectName: project.name) { content in
                store.addProgress(projectID: project.id, content: content)
            }
        }
        .onChange(of: store.loadError != nil) { _, isError in
            isShowingLoadError = isError
        }
        .onChange(of: store.saveError != nil) { _, isError in
            isShowingSaveError = isError
        }
        .alert("Research Board couldn’t read projects.json", isPresented: $isShowingLoadError) {
            Button("Open Data Folder") { store.openDataDirectory() }
            Button("Try Backup") { store.restoreLatestBackup() }
            Button("Dismiss", role: .cancel) { store.loadError = nil }
        } message: {
            Text("The original file has not been modified. You can open the data folder to inspect it or restore the latest backup.")
        }
        .alert("Research Board couldn’t save your changes", isPresented: $isShowingSaveError) {
            Button("Open Data Folder") { store.openDataDirectory() }
            Button("Dismiss", role: .cancel) { store.saveError = nil }
        } message: {
            Text(store.saveError?.localizedDescription ?? "Please check that the ResearchBoard folder is writable.")
        }
        .background(keyboardShortcuts)
    }

    private var boardContent: some View {
        Group {
            if store.activeProjects.isEmpty {
                EmptyStateView { isShowingNewProject = true }
                    .padding(.horizontal, 18)
            } else {
                ScrollView {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 220, maximum: 330), spacing: 14)],
                        spacing: 14
                    ) {
                        ForEach(store.activeProjects) { project in
                            NavigationLink(value: project.id) {
                                ProjectThumbnailView(project: project)
                            }
                            .buttonStyle(.plain)
                            .onTapGesture { store.selectedProjectID = project.id }
                            .onDrag {
                                store.selectedProjectID = project.id
                                return NSItemProvider(object: project.id.uuidString as NSString)
                            }
                            .onDrop(
                                of: [UTType.text],
                                delegate: ProjectDropDelegate(targetID: project.id, store: store)
                            )
                        }
                        Button {
                            isShowingNewProject = true
                        } label: {
                            Label("New Project", systemImage: "plus")
                                .font(.system(size: 13, weight: .semibold))
                                .frame(maxWidth: .infinity, minHeight: 142)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                    }
                    .padding(18)
                }
            }
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 15) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Research Board")
                    .font(.system(size: 23, weight: .semibold, design: .rounded))
                Text("\(store.activeProjects.count) active · \(store.attentionCount) need attention")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 10)
            Button {
                isShowingNewProject = true
            } label: {
                Label("New Project", systemImage: "plus")
                    .font(.system(size: 13, weight: .semibold))
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.regular)
            .keyboardShortcut("n", modifiers: .command)
            Menu {
                Button("Open Data Folder", systemImage: "folder") { store.openDataDirectory() }
                Button("Archived Projects", systemImage: "archivebox") { isShowingArchived = true }
                Divider()
                Button("About Research Board", systemImage: "info.circle") {
                    NSApplication.shared.orderFrontStandardAboutPanel(nil)
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 14, weight: .bold))
                    .frame(width: 30, height: 30)
                    .background(Color.primary.opacity(0.06), in: Circle())
            }
            .menuStyle(.borderlessButton)
            .help("More options")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
    }

    private var keyboardShortcuts: some View {
        HStack(spacing: 0) {
            Button("Edit selected project") {
                guard let id = store.selectedProjectID else { return }
                projectForEdit = store.project(withID: id)
            }
            .keyboardShortcut("e", modifiers: .command)
            Button("Add progress to selected project") {
                guard let id = store.selectedProjectID else { return }
                projectForProgress = store.project(withID: id)
            }
                .keyboardShortcut("r", modifiers: .command)
            Button("Open data folder") { store.openDataDirectory() }
                .keyboardShortcut("o", modifiers: .command)
        }
        .opacity(0.001)
        .frame(width: 1, height: 1)
    }
}

struct ProjectDropDelegate: DropDelegate {
    let targetID: UUID
    let store: ResearchStore

    func performDrop(info: DropInfo) -> Bool { true }

    func dropEntered(info: DropInfo) {
        guard let provider = info.itemProviders(for: [UTType.text]).first else { return }
        let visibleProjects = store.activeProjects
        provider.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { item, _ in
            let idString: String? = if let data = item as? Data {
                String(data: data, encoding: .utf8)
            } else if let string = item as? String {
                string
            } else if let string = item as? NSString {
                string as String
            } else {
                nil
            }
            guard let idString,
                  let sourceID = UUID(uuidString: idString),
                  sourceID != targetID,
                  let sourceIndex = visibleProjects.firstIndex(where: { $0.id == sourceID }),
                  let targetIndex = visibleProjects.firstIndex(where: { $0.id == targetID }) else { return }
            Task { @MainActor in
                store.moveProject(
                    fromOffsets: IndexSet(integer: sourceIndex),
                    toOffset: targetIndex > sourceIndex ? targetIndex + 1 : targetIndex
                )
            }
        }
    }
}
