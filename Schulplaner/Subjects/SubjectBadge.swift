import SwiftUI
import SchulplanerKit

/// A subject's symbol on its colour. Decorative: the name beside it is what
/// VoiceOver reads, and what tells subjects apart without colour.
struct SubjectBadge: View {
    let colorKey: String
    let symbolName: String
    var size: CGFloat = 30

    @ScaledMetric private var scale = 1.0

    var body: some View {
        Image(systemName: SubjectPalette.symbol(for: symbolName).name)
            .font(.system(size: size * scale * 0.5, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: size * scale, height: size * scale)
            .background(SubjectPalette.color(for: colorKey).color, in: .rect(cornerRadius: size * scale * 0.24))
            .accessibilityHidden(true)
    }
}

extension SubjectBadge {
    init(_ subject: Subject, size: CGFloat = 30) {
        self.init(colorKey: subject.colorKey, symbolName: subject.symbolName, size: size)
    }
}

/// A subject as a row: its badge and its name.
struct SubjectLabel: View {
    let name: String
    let colorKey: String
    let symbolName: String

    var body: some View {
        Label {
            Text(verbatim: name)
        } icon: {
            SubjectBadge(colorKey: colorKey, symbolName: symbolName)
        }
    }
}

extension SubjectLabel {
    init(_ subject: Subject) {
        self.init(name: subject.name, colorKey: subject.colorKey, symbolName: subject.symbolName)
    }
}

extension Subjects.Problem {
    /// What the screens say instead of saving.
    var message: LocalizedStringResource {
        switch self {
        case .empty: "Gib einen Namen ein."
        case let .taken(by: existing): "Das Fach „\(existing)“ gibt es schon."
        }
    }
}

extension SchulplanerKit.SubjectName.Verdict {
    var problem: Subjects.Problem? {
        switch self {
        case .valid: nil
        case .empty: .empty
        case let .taken(by: existing): .taken(by: existing)
        }
    }
}

/// Closes a sheet without saving: a cross from iOS 26 on, "Abbrechen" before.
struct CancelButton: View {
    let action: () -> Void

    var body: some View {
        if #available(iOS 26, *) {
            Button(role: .close, action: action)
        } else {
            Button("Abbrechen", action: action)
        }
    }
}
