import AppKit
import Foundation

enum ProjectRepositoryError: LocalizedError {
    case unsupportedSchema(Int)
    case invalidData(URL, underlying: Error)
    case noBackup
    case backupRestoreFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .unsupportedSchema(let version):
            return "This Research Board file uses an unsupported schema (version \(version))."
        case .invalidData:
            return "Research Board couldn't read projects.json."
        case .noBackup:
            return "No backup is available to restore."
        case .backupRestoreFailed(let error):
            return "The latest backup could not be restored: \(error.localizedDescription)"
        }
    }
}

final class ProjectRepository {
    private let fileManager: FileManager
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    func loadProjects() throws -> [ResearchProject] {
        try ensureDirectories()
        guard fileManager.fileExists(atPath: AppPaths.projectsFile.path) else { return [] }
        do {
            let data = try Data(contentsOf: AppPaths.projectsFile)
            let envelope = try decoder.decode(ResearchBoardData.self, from: data)
            guard envelope.schemaVersion == 1 else {
                throw ProjectRepositoryError.unsupportedSchema(envelope.schemaVersion)
            }
            return envelope.projects
        } catch let error as ProjectRepositoryError {
            throw error
        } catch {
            throw ProjectRepositoryError.invalidData(AppPaths.projectsFile, underlying: error)
        }
    }

    func saveProjects(_ projects: [ResearchProject]) throws {
        try ensureDirectories()
        let payload = ResearchBoardData(schemaVersion: 1, projects: projects)
        let data = try encoder.encode(payload)
        let temporaryURL = AppPaths.dataDirectory.appendingPathComponent("projects.json.tmp-\(UUID().uuidString)")
        try data.write(to: temporaryURL, options: .atomic)
        if fileManager.fileExists(atPath: AppPaths.projectsFile.path) {
            _ = try fileManager.replaceItemAt(AppPaths.projectsFile, withItemAt: temporaryURL)
        } else {
            try fileManager.moveItem(at: temporaryURL, to: AppPaths.projectsFile)
        }
    }

    func createBackup() throws {
        try ensureDirectories()
        guard fileManager.fileExists(atPath: AppPaths.projectsFile.path) else { return }
        let stamp = Self.backupFormatter.string(from: .now)
        var destination = AppPaths.backupsDirectory.appendingPathComponent("projects-\(stamp).json")
        var suffix = 1
        while fileManager.fileExists(atPath: destination.path) {
            destination = AppPaths.backupsDirectory.appendingPathComponent("projects-\(stamp)-\(suffix).json")
            suffix += 1
        }
        try fileManager.copyItem(at: AppPaths.projectsFile, to: destination)
        let backups = try backupFiles()
        for oldBackup in backups.dropLast(20) {
            try? fileManager.removeItem(at: oldBackup)
        }
    }

    func restoreLatestBackup() throws {
        do {
            try ensureDirectories()
            var validBackup: (URL, Data)?
            for backup in try backupFiles().reversed() {
                guard let data = try? Data(contentsOf: backup),
                      (try? decoder.decode(ResearchBoardData.self, from: data)) != nil else { continue }
                validBackup = (backup, data)
                break
            }
            guard let (_, data) = validBackup else { throw ProjectRepositoryError.noBackup }
            if fileManager.fileExists(atPath: AppPaths.projectsFile.path) {
                let stamp = Self.corruptFormatter.string(from: .now)
                var corruptURL = AppPaths.dataDirectory.appendingPathComponent("projects-corrupted-\(stamp).json")
                var suffix = 1
                while fileManager.fileExists(atPath: corruptURL.path) {
                    corruptURL = AppPaths.dataDirectory.appendingPathComponent("projects-corrupted-\(stamp)-\(suffix).json")
                    suffix += 1
                }
                try fileManager.copyItem(at: AppPaths.projectsFile, to: corruptURL)
            }
            let temporaryURL = AppPaths.dataDirectory.appendingPathComponent("projects.restore.tmp-\(UUID().uuidString)")
            try data.write(to: temporaryURL, options: .atomic)
            if fileManager.fileExists(atPath: AppPaths.projectsFile.path) {
                _ = try fileManager.replaceItemAt(AppPaths.projectsFile, withItemAt: temporaryURL)
            } else {
                try fileManager.moveItem(at: temporaryURL, to: AppPaths.projectsFile)
            }
        } catch let error as ProjectRepositoryError {
            throw error
        } catch {
            throw ProjectRepositoryError.backupRestoreFailed(underlying: error)
        }
    }

    func openDataDirectory() {
        try? ensureDirectories()
        NSWorkspace.shared.open(AppPaths.dataDirectory)
    }

    private func ensureDirectories() throws {
        try fileManager.createDirectory(at: AppPaths.dataDirectory, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: AppPaths.backupsDirectory, withIntermediateDirectories: true)
    }

    private func backupFiles() throws -> [URL] {
        try ensureDirectories()
        return try fileManager.contentsOfDirectory(
            at: AppPaths.backupsDirectory,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: [.skipsHiddenFiles]
        )
        .filter { $0.pathExtension == "json" && $0.lastPathComponent.hasPrefix("projects-") }
        .sorted { lhs, rhs in
            let left = (try? lhs.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
            let right = (try? rhs.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
            return left < right
        }
    }

    private static let backupFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        return formatter
    }()

    private static let corruptFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        return formatter
    }()
}
