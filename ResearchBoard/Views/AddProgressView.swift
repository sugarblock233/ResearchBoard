import SwiftUI

struct AddProgressView: View {
    let projectName: String
    let onAdd: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var content = ""
    @FocusState private var isFocused: Bool

    private var trimmedContent: String { content.trimmingCharacters(in: .whitespacesAndNewlines) }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            sheetHeader(title: "Add Progress", subtitle: projectName)
            LabeledField("What changed?", hint: "Up to 1,000 characters") {
                TextEditor(text: $content)
                    .font(.system(size: 14))
                    .scrollContentBackground(.hidden)
                    .focused($isFocused)
                    .frame(minHeight: 130)
                    .fieldContainer()
            }
            Text("Capture a finding or decision that changes the direction of the research.")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button("Add") {
                    onAdd(trimmedContent)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
                .disabled(trimmedContent.isEmpty || content.count > 1000)
            }
        }
        .padding(26)
        .frame(width: 500)
        .onAppear { isFocused = true }
    }
}

@ViewBuilder
func sheetHeader(title: String, subtitle: String? = nil) -> some View {
    VStack(alignment: .leading, spacing: 4) {
        Text(title)
            .font(.system(size: 22, weight: .semibold, design: .rounded))
        if let subtitle {
            Text(subtitle)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
        }
    }
}
