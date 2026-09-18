# Research Board

Research Board is a small, local-first macOS research cockpit built with SwiftUI. It keeps each project’s current stage, status, research question, current action, next action, and meaningful progress notes visible in one quiet dashboard.

## Run

- Open `ResearchBoard.xcodeproj` in Xcode and run the **ResearchBoard** target.
- The project targets macOS 14 Sonoma or later.
- A Swift Package entry point is included as well: `swift build`.
- If you want a standalone local bundle, run `./scripts/build-app.sh` and open `dist/ResearchBoard.app`.

The app does not need a server, network connection, database, or third-party framework.

## Data

On first launch the app creates:

```text
~/Documents/ResearchBoard/projects.json
~/Documents/ResearchBoard/backups/
```

Changes are written atomically. A startup backup is kept for every launch, with the newest 20 backups retained. If the JSON cannot be decoded, the original file remains untouched and the app offers to open the data folder or restore the newest valid backup.

## Interactions

- The default board is a compact thumbnail grid: each project shows its name, status, current stage, and a small segmented progress bar.
- Click a thumbnail to open the detailed project page. The detailed page keeps the full pipeline, research question, current/next actions, notes, and editing controls available.
- Click a stage to move the current stage after confirmation.
- Use the status capsule to change status.
- `⌘N` creates a project, `⌘E` edits the selected project, `⌘R` adds progress, and `⌘O` is available from the data-folder menu.
- Project editing includes a small pipeline editor, ten preset project colors, archive, and delete actions. A project color is saved independently from its status, so changing status does not recolor the project.

The interface uses native SwiftUI materials and semantic system colors so Light and Dark Mode follow macOS naturally.
