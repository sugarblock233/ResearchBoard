import SwiftUI
import UniformTypeIdentifiers

struct PipelineEditorView: View {
    @Binding var stages: [ResearchStage]
    @Binding var currentStageID: UUID
    @State private var newStageName = ""
    @State private var inlineError: String?
    @State private var draggedStageID: UUID?

    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            Text("PIPELINE")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(0.8)
                .foregroundStyle(.secondary)
            VStack(spacing: 6) {
                ForEach(stages.indices, id: \.self) { index in
                    HStack(spacing: 9) {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.tertiary)
                        TextField("Stage name", text: $stages[index].title)
                            .textFieldStyle(.plain)
                            .font(.system(size: 13, weight: .medium))
                            .onChange(of: stages[index].title) { _, newValue in
                                if newValue.count > 30 { stages[index].title = String(newValue.prefix(30)) }
                            }
                        if stages[index].id == currentStageID {
                            Text("CURRENT")
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .tracking(0.4)
                                .foregroundStyle(.tint)
                        }
                        Button {
                            removeStage(at: index)
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.secondary)
                                .frame(width: 23, height: 23)
                                .background(Color.primary.opacity(0.06), in: Circle())
                        }
                        .buttonStyle(.plain)
                        .disabled(stages.count <= 1)
                        .help(stages.count <= 1 ? "A pipeline needs at least one stage" : "Remove stage")
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                    .onDrag {
                        draggedStageID = stages[index].id
                        return NSItemProvider(object: stages[index].id.uuidString as NSString)
                    }
                    .onDrop(of: [UTType.text], delegate: PipelineStageDropDelegate(
                        targetID: stages[index].id,
                        stages: $stages,
                        draggedStageID: $draggedStageID
                    ))
                }
            }
            HStack(spacing: 8) {
                TextField("New stage", text: $newStageName)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit(addStage)
                Button("Add", systemImage: "plus") { addStage() }
                    .buttonStyle(.bordered)
                    .disabled(newStageName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            if let inlineError {
                Label(inlineError, systemImage: "exclamationmark.circle")
                    .font(.system(size: 11))
                    .foregroundStyle(.orange)
            }
        }
    }

    private func addStage() {
        let name = newStageName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        stages.append(ResearchStage(title: String(name.prefix(30))))
        newStageName = ""
        inlineError = nil
    }

    private func removeStage(at index: Int) {
        guard stages.count > 1 else {
            inlineError = "A pipeline must keep at least one stage."
            return
        }
        guard stages[index].id != currentStageID else {
            inlineError = "Choose another current stage before deleting this one."
            return
        }
        stages.remove(at: index)
        inlineError = nil
    }

}

struct PipelineStageDropDelegate: DropDelegate {
    let targetID: UUID
    @Binding var stages: [ResearchStage]
    @Binding var draggedStageID: UUID?

    func dropEntered(info: DropInfo) {
        guard let draggedStageID,
              draggedStageID != targetID,
              let sourceIndex = stages.firstIndex(where: { $0.id == draggedStageID }),
              let targetIndex = stages.firstIndex(where: { $0.id == targetID }) else { return }
        withAnimation(.easeInOut(duration: 0.12)) {
            stages.move(fromOffsets: IndexSet(integer: sourceIndex), toOffset: targetIndex > sourceIndex ? targetIndex + 1 : targetIndex)
        }
    }

    func performDrop(info: DropInfo) -> Bool {
        draggedStageID = nil
        return true
    }
}
