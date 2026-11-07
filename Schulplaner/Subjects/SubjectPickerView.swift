import SchulplanerKit
import SwiftData
import SwiftUI

/// Choosing subjects: from the suggestions, several at once, and by typing
/// any other name. The first screen of the app, as long as there are no
/// subjects, and later the way to add more.
struct SubjectPickerView: View {
    enum Purpose {
        case firstLaunch
        case addMore
    }

    let purpose: Purpose

    @Environment(\.subjects) private var subjects
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Subject.sortIndex) private var existing: [Subject]

    @State private var chosen: Set<String> = []
    @State private var ownNames: [String] = []
    @State private var typed = ""
    @State private var problem: Subjects.Problem?
    @State private var failed = false

    var body: some View {
        List {
            if purpose == .firstLaunch {
                Section {
                    Text("Wähle die Fächer, die du hast. Du kannst sie später jederzeit ändern.")
                }
            }

            Section("Vorschläge") {
                ForEach(available) { suggestion in
                    let isChosen = chosen.contains(suggestion.id)
                    Button {
                        if isChosen { chosen.remove(suggestion.id) } else { chosen.insert(suggestion.id) }
                    } label: {
                        HStack {
                            SubjectLabel(
                                name: String(localized: suggestion.name),
                                colorKey: suggestion.colorKey,
                                symbolName: suggestion.symbolName
                            )
                            Spacer()
                            Image(systemName: isChosen ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(isChosen ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
                                .accessibilityHidden(true)
                        }
                    }
                    .foregroundStyle(.primary)
                    .accessibilityAddTraits(isChosen ? .isSelected : [])
                }
            }

            Section {
                HStack {
                    TextField("Anderes Fach", text: $typed)
                        .submitLabel(.done)
                        .onSubmit(addTyped)
                    Button("Hinzufügen", action: addTyped)
                        .disabled(typed.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                ForEach(Array(zip(ownNames, ownColors)), id: \.0) { name, colorKey in
                    HStack {
                        SubjectLabel(name: name, colorKey: colorKey, symbolName: SubjectPalette.fallbackSymbol.name)
                        Spacer()
                        Button("\(name) entfernen", systemImage: "minus.circle.fill") {
                            ownNames.removeAll { $0 == name }
                        }
                        .labelStyle(.iconOnly)
                        .foregroundStyle(.red)
                    }
                }
            } header: {
                Text("Eigenes Fach")
            } footer: {
                if let problem {
                    Text(problem.message).foregroundStyle(.red)
                }
            }
        }
        .navigationTitle(purpose == .firstLaunch ? "Deine Fächer" : "Fächer hinzufügen")
        .toolbar {
            if purpose == .addMore {
                ToolbarItem(placement: .cancellationAction) {
                    CancelButton { dismiss() }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: addChosen) {
                Group {
                    if drafts.isEmpty {
                        Text("Fächer hinzufügen")
                    } else {
                        Text("\(drafts.count) Fächer hinzufügen")
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(drafts.isEmpty)
            .padding()
            .background(.bar)
        }
        .alert("Die Fächer konnten nicht gesichert werden.", isPresented: $failed) {}
        .onChange(of: typed) { problem = nil }
    }

    /// Suggestions whose name no subject has yet.
    private var available: [SubjectPalette.Suggestion] {
        let names = existing.map(\.name)
        return SubjectPalette.suggestions.filter {
            if case .valid = SubjectName.check(String(localized: $0.name), against: names) { true } else { false }
        }
    }

    private var drafts: [Subjects.Draft] {
        let picked = available.filter { chosen.contains($0.id) }.map {
            Subjects.Draft(name: String(localized: $0.name), colorKey: $0.colorKey, symbolName: $0.symbolName)
        }
        let typed = zip(ownNames, ownColors).map { name, colorKey in
            Subjects.Draft(name: name, colorKey: colorKey, symbolName: SubjectPalette.fallbackSymbol.name)
        }
        return picked + typed
    }

    /// Each typed subject gets a colour that no other subject has yet, as far
    /// as the palette goes.
    private var ownColors: [String] {
        var used = existing.map(\.colorKey) + available.filter { chosen.contains($0.id) }.map(\.colorKey)
        return ownNames.map { _ in
            let key = SubjectPalette.unusedColor(besides: used).key
            used.append(key)
            return key
        }
    }

    private func addTyped() {
        // A typed name that is one of the suggestions picks the suggestion,
        // with its colour and symbol.
        if let suggestion = available.first(where: {
            if case .taken = SubjectName.check(typed, against: [String(localized: $0.name)]) { true } else { false }
        }) {
            chosen.insert(suggestion.id)
            typed = ""
            return
        }
        let others = existing.map(\.name) + drafts.map(\.name)
        switch SubjectName.check(typed, against: others) {
        case let .valid(name):
            ownNames.append(name)
            typed = ""
        case let verdict:
            problem = verdict.problem
        }
    }

    private func addChosen() {
        do {
            try subjects.add(drafts)
            if purpose == .addMore { dismiss() }
        } catch {
            failed = true
        }
    }
}

#Preview("Erster Start") {
    NavigationStack {
        SubjectPickerView(purpose: .firstLaunch)
    }
    .modelContainer(try! Store.container(.memory))
}
