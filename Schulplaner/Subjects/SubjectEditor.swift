import SchulplanerKit
import SwiftUI

/// One subject: its name, colour and symbol.
struct SubjectEditor: View {
    let subject: Subject

    @Environment(\.subjects) private var subjects
    @Environment(\.dismiss) private var dismiss
    @ScaledMetric private var cell = 44.0

    @State private var name: String
    @State private var colorKey: String
    @State private var symbolName: String
    @State private var failed = false

    init(subject: Subject) {
        self.subject = subject
        _name = State(initialValue: subject.name)
        _colorKey = State(initialValue: subject.colorKey)
        _symbolName = State(initialValue: subject.symbolName)
    }

    var body: some View {
        Form {
            Section {
                SubjectBadge(colorKey: colorKey, symbolName: symbolName, size: 64)
                    .frame(maxWidth: .infinity)
            }
            .listRowBackground(Color.clear)

            Section {
                TextField("Name", text: $name)
            } header: {
                Text("Name")
            } footer: {
                if let problem {
                    Text(problem.message).foregroundStyle(.red)
                }
            }

            Section("Farbe") {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: cell))], spacing: 12) {
                    ForEach(SubjectPalette.colors) { option in
                        let selected = option.key == colorKey
                        Button {
                            colorKey = option.key
                        } label: {
                            Circle()
                                .fill(option.color)
                                .frame(width: cell, height: cell)
                                .overlay {
                                    if selected {
                                        Image(systemName: "checkmark")
                                            .font(.body.weight(.bold))
                                            .foregroundStyle(.white)
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(Text(option.name))
                        .accessibilityAddTraits(selected ? .isSelected : [])
                    }
                }
                .padding(.vertical, 4)
            }

            Section("Symbol") {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: cell))], spacing: 12) {
                    ForEach(SubjectPalette.symbols) { option in
                        let selected = option.name == symbolName
                        Button {
                            symbolName = option.name
                        } label: {
                            Image(systemName: option.name)
                                .font(.title3)
                                .frame(width: cell, height: cell)
                                .foregroundStyle(selected ? .white : .primary)
                                .background(
                                    selected ? AnyShapeStyle(SubjectPalette.color(for: colorKey).color) : AnyShapeStyle(.fill.tertiary),
                                    in: .rect(cornerRadius: cell * 0.24)
                                )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(Text(option.label))
                        .accessibilityAddTraits(selected ? .isSelected : [])
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Fach bearbeiten")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                CancelButton { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                // iOS 26 shows a checkmark, which leaves the title room on
                // small screens with large text.
                Group {
                    if #available(iOS 26, *) {
                        Button(role: .confirm, action: save)
                    } else {
                        Button("Sichern", action: save)
                    }
                }
                .disabled(problem != nil)
            }
        }
        .alert("Das Fach konnte nicht gesichert werden.", isPresented: $failed) {}
    }

    /// What the name rule says about the name as typed, if anything.
    private var problem: Subjects.Problem? {
        (try? subjects.check(name, renaming: subject))?.problem
    }

    private func save() {
        do {
            try subjects.update(subject, name: name, colorKey: colorKey, symbolName: symbolName)
            dismiss()
        } catch {
            failed = true
        }
    }
}
