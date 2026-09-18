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
        .defaultSize(width: 1000, height: 760)
        .commands {
            CommandGroup(replacing: .help) {
                Button("Research Board Help") {
                    NSApplication.shared.orderFrontStandardAboutPanel(nil)
                }
            }
        }
    }
}
