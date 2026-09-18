import SwiftUI

struct ProjectEditorView: View {
    enum Mode {
        case new
        case edit(ResearchProject)

        var title: String {
            switch self {
            case .new: "New Project"
            case .edit: "Edit Project"
            }
        }
    }

    let mode: Mode
    let onSave: (ResearchProject) -> Void
    var onArchive: (() -> Void)?
    var onDelete: (() -> Void)?

    @Environment(\.dismiss) private var dismiss
    @State private var draft: ResearchProject
    @State private var validationMessage: String?
    @State private var isShowingDeleteConfirmation = false

    init(
        mode: Mode,
        onSave: @escaping (ResearchProject) -> Void,
        onArchive: (() -> Void)? = nil,
        onDelete: (() -> Void)? = nil
    ) {
        self.mode = mode
        self.onSave = onSave
        self.onArchive = onArchive
        self.onDelete = onDelete
        switch mode {
        case .new:
            _draft = State(initialValue: ResearchProject(name: ""))
        case .edit(let project):
            _draft = State(initialValue: project)
        }
    }

    private var nameIsValid: Bool {
        let name = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return !name.isEmpty && name.count <= 80
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            sheetHeader(title: mode.title, subtitle: modeSubtitle)
                .padding(.bottom, 22)
            ScrollView {
                VStack(alignment: .leading, spacing: 21) {
                    LabeledField("Project Name", hint: "1–80 characters") {
                        TextField("e.g. A new research project", text: $draft.name)
                            .textFieldStyle(.plain)
                            .font(.system(size: 14, weight: .medium))
                            .fieldContainer()
                            .onChange(of: draft.name) { _, newValue in
                                if newValue.count > 80 { draft.name = String(newValue.prefix(80)) }
                            }
                    }
                    PipelineEditorView(stages: $draft.stages, currentStageID: $draft.currentStageID)
                    LabeledField("Project Color", hint: "Used for the compact board") {
                        HStack(spacing: 9) {
                            ForEach(ProjectColor.allCases) { color in
                                Button {
                                    draft.color = color
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(color.accent)
                                            .frame(width: 24, height: 24)
                                        if draft.color == color {
                                            Circle()
                                                .strokeBorder(.white.opacity(0.9), lineWidth: 2)
                                                .frame(width: 18, height: 18)
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                                .help(color.title)
                                .accessibilityLabel("\(color.title) project color")
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    HStack(alignment: .top, spacing: 16) {
                        LabeledField("Current Stage") {
                            Picker("Current Stage", selection: $draft.currentStageID) {
                                ForEach(draft.stages) { stage in
                                    Text(stage.title.isEmpty ? "Untitled stage" : stage.title).tag(stage.id)
                                }
                            }
                            .labelsHidden()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fieldContainer()
                        }
                        LabeledField("Status") {
                            Picker("Status", selection: $draft.status) {
                                ForEach(ProjectStatus.allCases) { status in
                                    Label(status.title, systemImage: status.symbol).tag(status)
                                }
                            }
                            .labelsHidden()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fieldContainer()
                        }
                    }
                    LabeledField("Current Question", hint: "Up to 300 characters") {
                        TextEditor(text: $draft.question)
                            .font(.system(size: 13))
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 68)
                            .fieldContainer()
                            .onChange(of: draft.question) { _, newValue in
                                if newValue.count > 300 { draft.question = String(newValue.prefix(300)) }
                            }
                    }
                    HStack(alignment: .top, spacing: 16) {
                        labeledEditor("Current", text: $draft.currentAction)
                        labeledEditor("Next", text: $draft.nextAction)
                    }
                    if let validationMessage {
                        Label(validationMessage, systemImage: "exclamationmark.circle")
                            .font(.system(size: 12))
                            .foregroundStyle(.orange)
                    }
                    if case .edit = mode {
                        Divider().padding(.top, 4)
                        HStack(spacing: 10) {
                            if let onArchive {
                                Button("Archive Project", systemImage: "archivebox") {
                                    onArchive()
                                    dismiss()
                                }
                                .buttonStyle(.bordered)
                            }
                            if onDelete != nil {
                                Button("Delete Project", systemImage: "trash", role: .destructive) {
                                    isShowingDeleteConfirmation = true
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                }
                .padding(.bottom, 8)
            }
            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button(isNewMode ? "Create Project" : "Save Changes") {
                    save()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
                .disabled(!nameIsValid)
            }
            .padding(.top, 20)
        }
        .padding(28)
        .frame(width: 640, height: 700)
        .confirmationDialog("Delete this project?", isPresented: $isShowingDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                onDelete?()
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This cannot be undone from the app. A backup may still exist in the ResearchBoard backup folder.")
        }
    }

    private var modeSubtitle: String? {
        switch mode {
        case .new: "Give the work a clear home and a next move."
        case .edit: "Keep the project’s current state easy to see."
        }
    }

    private var isNewMode: Bool {
        if case .new = mode { return true }
        return false
    }

    private func labeledEditor(_ title: String, text: Binding<String>) -> some View {
        LabeledField(title, hint: "Up to 300 characters") {
            TextEditor(text: text)
                .font(.system(size: 13))
                .scrollContentBackground(.hidden)
                .frame(minHeight: 70)
                .fieldContainer()
                .onChange(of: text.wrappedValue) { _, value in
                    if value.count > 300 { text.wrappedValue = String(value.prefix(300)) }
                }
        }
    }

    private func save() {
        let cleanedName = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedName.isEmpty else {
            validationMessage = "Project name is required."
            return
        }
        guard !draft.stages.isEmpty, draft.stages.allSatisfy({ !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) else {
            validationMessage = "Every pipeline stage needs a name."
            return
        }
        draft.name = String(cleanedName.prefix(80))
        draft.stages = draft.stages.map { stage in
            var stage = stage
            stage.title = String(stage.title.trimmingCharacters(in: .whitespacesAndNewlines).prefix(30))
            return stage
        }
        draft.question = String(draft.question.prefix(300))
        draft.currentAction = String(draft.currentAction.prefix(300))
        draft.nextAction = String(draft.nextAction.prefix(300))
        onSave(draft)
        dismiss()
    }
}
