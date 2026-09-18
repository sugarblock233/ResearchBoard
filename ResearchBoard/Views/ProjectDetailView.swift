import SwiftUI

struct ProjectDetailView: View {
    @EnvironmentObject private var store: ResearchStore
    let projectID: UUID

    var body: some View {
        ScrollView {
            if let project = store.project(withID: projectID) {
                ProjectCardView(project: project, startExpanded: true, allowsToggle: false)
                    .environmentObject(store)
                    .frame(maxWidth: 980)
                    .padding(24)
            } else {
                ContentUnavailableView("Project unavailable", systemImage: "questionmark.folder")
                    .frame(maxWidth: .infinity, minHeight: 400)
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .navigationTitle(store.project(withID: projectID)?.name ?? "Project")
        .navigationSubtitle("Detailed view")
        .onAppear { store.selectedProjectID = projectID }
    }
}
