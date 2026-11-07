import Testing
import UIKit
@testable import Schulplaner

/// The palette, the symbols and the suggestions fit together.
struct SubjectPaletteTests {
    @Test(arguments: SubjectPalette.symbols.map(\.name))
    func everySymbolExistsOnThisIOS(_ name: String) {
        #expect(UIImage(systemName: name) != nil)
    }

    @Test func everySuggestionUsesTheCuratedColoursAndSymbols() {
        let colors = Set(SubjectPalette.colors.map(\.key))
        let symbols = Set(SubjectPalette.symbols.map(\.name))
        for suggestion in SubjectPalette.suggestions {
            #expect(colors.contains(suggestion.colorKey), "\(suggestion.id)")
            #expect(symbols.contains(suggestion.symbolName), "\(suggestion.id)")
        }
    }

    @Test func keysAndNamesAreUnique() {
        #expect(Set(SubjectPalette.colors.map(\.key)).count == SubjectPalette.colors.count)
        #expect(Set(SubjectPalette.symbols.map(\.name)).count == SubjectPalette.symbols.count)
        #expect(Set(SubjectPalette.suggestions.map(\.id)).count == SubjectPalette.suggestions.count)
    }

    @Test func anUnknownStoredValueShowsAsTheFallback() {
        #expect(SubjectPalette.color(for: "ultraviolet") == SubjectPalette.fallbackColor)
        #expect(SubjectPalette.symbol(for: "no.such.symbol") == SubjectPalette.fallbackSymbol)
    }

    @Test func aTypedSubjectGetsAColourNoOtherHas() {
        #expect(SubjectPalette.unusedColor(besides: ["red", "orange"]).key == "green")
        #expect(SubjectPalette.unusedColor(besides: SubjectPalette.colors.map(\.key)) == SubjectPalette.fallbackColor)
    }
}
