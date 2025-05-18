//
//  TextStyle.swift
//  TESTTASK
//
//  Created by Ivan Kisilov on 14.05.2025.
//


import SwiftUI

// MARK: - Custom Text Style Modifier
struct TextStyle: ViewModifier {
    var name: String
    var size: CGFloat
    var lineHeight: CGFloat

    func body(content: Content) -> some View {
        content
            .font(.custom(name, size: size))
            .lineSpacing(lineHeight - size)
    }
}

// MARK: - View Extensions for Text Styles
extension View {
    /// Heading 1 — Semibold 600, Size 16, Line height 24
    func heading1() -> some View {
        self.modifier(TextStyle(name: "NunitoSans-12ptExtraLight_Semibold", size: 16, lineHeight: 24))
    }
    /// Heading 2 — Regular 400, Size 20, Line height 24
    func heading2() -> some View {
        self.modifier(TextStyle(name: "NunitoSans-12ptExtraLight_Regular", size: 20, lineHeight: 24))
    }
    /// Body 1 — Regular 400, Size 18, Line height 24
    func body1() -> some View {
        self.modifier(TextStyle(name: "NunitoSans-12ptExtraLight_Regular", size: 18, lineHeight: 24))
    }

    /// Body 2 — Regular 400, Size 16, Line height 24
    func body2() -> some View {
        self.modifier(TextStyle(name: "NunitoSans-12ptExtraLight_Regular", size: 16, lineHeight: 24))
    }

    /// Body 3 — Regular 400, Size 14, Line height 20
    func body3() -> some View {
        self.modifier(TextStyle(name: "NunitoSans-12ptExtraLight_Regular", size: 14, lineHeight: 20))
    }
}
