import SwiftUI

@main
struct ResearchBoardApp: App {
    @StateObject private var store = ResearchStore()

    var body: some Scene {
        WindowGroup("Research Board") {
            DashboardView()
                .environmentObject(store)
                .preferredColorScheme(nil)
        }
        .defaultSize(width: 760, height: 540)
        .commands {
            CommandGroup(replacing: .help) {
                Button("Research Board Help") {
                    NSApplication.shared.orderFrontStandardAboutPanel(nil)
                }
            }
        }
    }
}
