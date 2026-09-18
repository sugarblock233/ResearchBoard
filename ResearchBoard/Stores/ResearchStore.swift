import Foundation
import SwiftUI

@MainActor
final class ResearchStore: ObservableObject {
    @Published private(set) var projects: [ResearchProject] = []
    @Published var selectedProjectID: UUID?
    @Published var loadError: ProjectRepositoryError?
    @Published var saveError: Error?

    let repository: ProjectRepository

    init(repository: ProjectRepository = ProjectRepository()) {
        self.repository = repository
        load()
    }

    var activeProjects: [ResearchProject] {
        projects.filter { !$0.isArchived }.sorted(by: projectSort)
    }

    var archivedProjects: [ResearchProject] {
        projects.filter(\.isArchived).sorted { $0.updatedAt > $1.updatedAt }
    }

    var attentionCount: Int {
        activeProjects.filter { $0.status.needsAttention }.count
    }

    func load() {
        do {
            try repository.createBackup()
            projects = try repository.loadProjects()
            normalizeSortOrders()
            loadError = nil
        } catch let error as ProjectRepositoryError {
            loadError = error
        } catch {
            loadError = .invalidData(AppPaths.projectsFile, underlying: error)
        }
    }

    func addProject(_ project: ResearchProject) {
        var project = project
        project.sortOrder = (projects.map(\.sortOrder).max() ?? -1) + 1
        project.updatedAt = .now
        projects.append(project)
        persist()
    }

    func updateProject(_ project: ResearchProject) {
        guard let index = projects.firstIndex(where: { $0.id == project.id }) else { return }
        var updated = project
        updated.updatedAt = .now
        projects[index] = updated
        persist()
    }

    func deleteProject(id: UUID) {
        projects.removeAll { $0.id == id }
        if selectedProjectID == id { selectedProjectID = nil }
        persist()
    }

    func archiveProject(id: UUID) {
        guard var project = project(withID: id) else { return }
        project.isArchived = true
        updateProject(project)
    }

    func restoreProject(id: UUID) {
        guard var project = project(withID: id) else { return }
        project.isArchived = false
        project.sortOrder = (projects.filter { !$0.isArchived }.map(\.sortOrder).max() ?? -1) + 1
        updateProject(project)
    }

    func moveProject(fromOffsets: IndexSet, toOffset: Int) {
        var visible = activeProjects
        visible.move(fromOffsets: fromOffsets, toOffset: toOffset)
        let ids = visible.map(\.id)
        for (index, id) in ids.enumerated() {
            guard let projectIndex = projects.firstIndex(where: { $0.id == id }) else { continue }
            projects[projectIndex].sortOrder = index
            projects[projectIndex].updatedAt = .now
        }
        persist()
    }

    func addProgress(projectID: UUID, content: String) {
        guard let index = projects.firstIndex(where: { $0.id == projectID }) else { return }
        let cleaned = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return }
        projects[index].notes.insert(ProgressNote(content: cleaned), at: 0)
        projects[index].updatedAt = .now
        persist()
    }

    func changeStage(projectID: UUID, stageID: UUID) {
        guard let index = projects.firstIndex(where: { $0.id == projectID }),
              projects[index].stages.contains(where: { $0.id == stageID }) else { return }
        projects[index].currentStageID = stageID
        projects[index].updatedAt = .now
        persist()
    }

    func changeStatus(projectID: UUID, status: ProjectStatus) {
        guard let index = projects.firstIndex(where: { $0.id == projectID }) else { return }
        projects[index].status = status
        projects[index].updatedAt = .now
        persist()
    }

    func project(withID id: UUID) -> ResearchProject? {
        projects.first { $0.id == id }
    }

    func restoreLatestBackup() {
        do {
            try repository.restoreLatestBackup()
            projects = try repository.loadProjects()
            normalizeSortOrders()
            loadError = nil
        } catch let error as ProjectRepositoryError {
            loadError = error
        } catch {
            loadError = .invalidData(AppPaths.projectsFile, underlying: error)
        }
    }

    func openDataDirectory() {
        repository.openDataDirectory()
    }

    private func persist() {
        do {
            try repository.saveProjects(projects)
            saveError = nil
        } catch {
            saveError = error
        }
    }

    private func normalizeSortOrders() {
        let ordered = projects.sorted { lhs, rhs in
            if lhs.sortOrder == rhs.sortOrder { return lhs.updatedAt < rhs.updatedAt }
            return lhs.sortOrder < rhs.sortOrder
        }
        for (index, project) in ordered.enumerated() {
            guard let projectIndex = projects.firstIndex(where: { $0.id == project.id }) else { continue }
            projects[projectIndex].sortOrder = index
        }
    }

    private func projectSort(_ lhs: ResearchProject, _ rhs: ResearchProject) -> Bool {
        if lhs.sortOrder == rhs.sortOrder { return lhs.updatedAt > rhs.updatedAt }
        return lhs.sortOrder < rhs.sortOrder
    }
}
