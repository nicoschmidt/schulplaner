import SwiftUI

/// The colours and symbols a subject can have, and the subjects the app
/// suggests. Colour is never the only cue: every subject also shows its symbol
/// and its name, for dark mode and for colour-vision deficiencies alike.
enum SubjectPalette {
    struct SubjectColor: Identifiable, Hashable {
        /// What is stored in `Subject.colorKey`. Never renamed: a stored key the
        /// app no longer knows shows as the fallback.
        let key: String
        let name: LocalizedStringResource
        let color: Color

        var id: String { key }

        static func == (lhs: Self, rhs: Self) -> Bool { lhs.key == rhs.key }
        func hash(into hasher: inout Hasher) { hasher.combine(key) }
    }

    struct SubjectSymbol: Identifiable, Hashable {
        /// The SF Symbol, stored in `Subject.symbolName`.
        let name: String
        let label: LocalizedStringResource

        var id: String { name }

        static func == (lhs: Self, rhs: Self) -> Bool { lhs.name == rhs.name }
        func hash(into hasher: inout Hasher) { hasher.combine(name) }
    }

    struct Suggestion: Identifiable {
        let name: LocalizedStringResource
        let colorKey: String
        let symbolName: String

        var id: String { name.key }
    }

    // System colours: they adapt to dark mode. White symbols stay readable on
    // all of them, which is why yellow, mint and cyan are not among them.
    static let colors: [SubjectColor] = [
        SubjectColor(key: "red", name: "Rot", color: .red),
        SubjectColor(key: "orange", name: "Orange", color: .orange),
        SubjectColor(key: "green", name: "Grün", color: .green),
        SubjectColor(key: "teal", name: "Türkis", color: .teal),
        SubjectColor(key: "blue", name: "Blau", color: .blue),
        SubjectColor(key: "indigo", name: "Indigo", color: .indigo),
        SubjectColor(key: "purple", name: "Lila", color: .purple),
        SubjectColor(key: "pink", name: "Pink", color: .pink),
        SubjectColor(key: "brown", name: "Braun", color: .brown),
        SubjectColor(key: "gray", name: "Grau", color: .gray),
    ]

    static let symbols: [SubjectSymbol] = [
        SubjectSymbol(name: "book.closed", label: "Buch"),
        SubjectSymbol(name: "function", label: "Funktion"),
        SubjectSymbol(name: "bubble.left.and.bubble.right", label: "Sprechblasen"),
        SubjectSymbol(name: "character.book.closed", label: "Wörterbuch"),
        SubjectSymbol(name: "building.columns", label: "Säulen"),
        SubjectSymbol(name: "leaf", label: "Blatt"),
        SubjectSymbol(name: "flask", label: "Kolben"),
        SubjectSymbol(name: "atom", label: "Atom"),
        SubjectSymbol(name: "hourglass", label: "Sanduhr"),
        SubjectSymbol(name: "globe.europe.africa", label: "Globus"),
        SubjectSymbol(name: "person.3", label: "Menschen"),
        SubjectSymbol(name: "paintpalette", label: "Farbpalette"),
        SubjectSymbol(name: "music.note", label: "Note"),
        SubjectSymbol(name: "figure.run", label: "Laufen"),
        SubjectSymbol(name: "heart", label: "Herz"),
        SubjectSymbol(name: "lightbulb", label: "Glühbirne"),
        SubjectSymbol(name: "desktopcomputer", label: "Computer"),
        SubjectSymbol(name: "chart.line.uptrend.xyaxis", label: "Diagramm"),
        SubjectSymbol(name: "wrench.and.screwdriver", label: "Werkzeug"),
        SubjectSymbol(name: "theatermasks", label: "Masken"),
    ]

    /// Common subjects at German schools, each with a fitting colour and symbol.
    static let suggestions: [Suggestion] = [
        Suggestion(name: "Deutsch", colorKey: "red", symbolName: "book.closed"),
        Suggestion(name: "Mathematik", colorKey: "blue", symbolName: "function"),
        Suggestion(name: "Englisch", colorKey: "indigo", symbolName: "bubble.left.and.bubble.right"),
        Suggestion(name: "Französisch", colorKey: "pink", symbolName: "bubble.left.and.bubble.right"),
        Suggestion(name: "Spanisch", colorKey: "orange", symbolName: "bubble.left.and.bubble.right"),
        Suggestion(name: "Latein", colorKey: "purple", symbolName: "character.book.closed"),
        Suggestion(name: "Biologie", colorKey: "green", symbolName: "leaf"),
        Suggestion(name: "Chemie", colorKey: "teal", symbolName: "flask"),
        Suggestion(name: "Physik", colorKey: "indigo", symbolName: "atom"),
        Suggestion(name: "Geschichte", colorKey: "brown", symbolName: "hourglass"),
        Suggestion(name: "Erdkunde", colorKey: "green", symbolName: "globe.europe.africa"),
        Suggestion(name: "Politik", colorKey: "gray", symbolName: "building.columns"),
        Suggestion(name: "Religion", colorKey: "purple", symbolName: "heart"),
        Suggestion(name: "Ethik", colorKey: "teal", symbolName: "lightbulb"),
        Suggestion(name: "Kunst", colorKey: "pink", symbolName: "paintpalette"),
        Suggestion(name: "Musik", colorKey: "orange", symbolName: "music.note"),
        Suggestion(name: "Sport", colorKey: "red", symbolName: "figure.run"),
        Suggestion(name: "Informatik", colorKey: "blue", symbolName: "desktopcomputer"),
        Suggestion(name: "Wirtschaft", colorKey: "brown", symbolName: "chart.line.uptrend.xyaxis"),
        Suggestion(name: "Technik", colorKey: "gray", symbolName: "wrench.and.screwdriver"),
    ]

    static let fallbackColor = colors[colors.count - 1]
    static let fallbackSymbol = symbols[0]

    static func color(for key: String) -> SubjectColor {
        colors.first { $0.key == key } ?? fallbackColor
    }

    static func symbol(for name: String) -> SubjectSymbol {
        symbols.first { $0.name == name } ?? fallbackSymbol
    }

    /// A colour for a subject the student types in: the first one no subject
    /// has yet, so that new subjects stand apart.
    static func unusedColor(besides used: [String]) -> SubjectColor {
        colors.first { !used.contains($0.key) } ?? fallbackColor
    }
}
