import Foundation

enum AppPaths {
    static var dataDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("ResearchBoard", isDirectory: true)
    }

    static var projectsFile: URL {
        dataDirectory.appendingPathComponent("projects.json")
    }

    static var backupsDirectory: URL {
        dataDirectory.appendingPathComponent("backups", isDirectory: true)
    }
}
