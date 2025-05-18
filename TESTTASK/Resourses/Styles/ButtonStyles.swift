//
//  PrimaryButtonStyle.swift
//  TESTTASK
//
//  Created by Ivan Kisilov on 18.05.2025.
//

import SwiftUI

// MARK: – Головна жовта (filled)
struct PrimaryButtonStyle: ButtonStyle {
    var enabled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        return configuration.label
            .font(.headline)
            .foregroundColor(.black.opacity(enabled ? 1 : 0.4))
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(bgColor(pressed: pressed))
            )
            .animation(.easeInOut(duration: 0.15), value: pressed)
            .opacity(enabled ? 1 : 0.6)
    }

    private func bgColor(pressed: Bool) -> Color {
        if !enabled   { return Color.gray.opacity(0.35) }
        if  pressed   { return Color.customPrimary.opacity(0.75) }
        return Color.customPrimary
    }
}

// MARK: – Додаткова блакитна (text)
struct SecondaryButtonStyle: ButtonStyle {
    var enabled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        return configuration.label
            .font(.headline)
            .foregroundColor(textColor(pressed: pressed))
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(
                Capsule()
                    .fill(bgColor(pressed: pressed))
            )
            .animation(.easeInOut(duration: 0.15), value: pressed)
            .opacity(enabled ? 1 : 0.6)
    }

    private func textColor(pressed: Bool) -> Color {
        if !enabled { return Color.gray }
        return Color.customSecondary
    }
    private func bgColor(pressed: Bool) -> Color {
        if !enabled { return Color.clear }
        if  pressed { return Color.customSecondary.opacity(0.15) }
        return Color.clear
    }
}

// MARK: – Зручні шорткати
extension View {
    func primaryButton(enabled: Bool = true) -> some View {
        self.buttonStyle(PrimaryButtonStyle(enabled: enabled))
    }
    func secondaryButton(enabled: Bool = true) -> some View {
        self.buttonStyle(SecondaryButtonStyle(enabled: enabled))
    }
}
