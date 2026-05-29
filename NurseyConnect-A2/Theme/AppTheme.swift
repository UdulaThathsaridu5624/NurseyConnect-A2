//
//  AppTheme.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

import SwiftUI

// MARK: - Colors

extension Color {
    static let nurseryPrimary    = Color("PrimaryGreen")
    static let nurseryTeal       = Color("PrimaryTeal")
    static let nurseryAccent     = Color("AccentOrange")
    static let nurseryBackground = Color("BackgroundPrimary")
    static let nurseryCard       = Color("CardBackground")
}

// MARK: - Fonts

extension Font {
    static let cardTitle   = Font.system(.headline,    design: .rounded, weight: .semibold)
    static let sectionHead = Font.system(.subheadline, design: .rounded, weight: .bold)
    static let bodySmall   = Font.system(.footnote,    design: .rounded)
    static let displayName = Font.system(.title3,      design: .rounded, weight: .bold)
}

// MARK: - Spacing

enum AppSpacing {
    static let xs: CGFloat =  4
    static let sm: CGFloat =  8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}

// MARK: - Amount Button Style

struct AmountButtonStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.caption, design: .rounded, weight: isSelected ? .bold : .regular))
            .foregroundStyle(isSelected ? .white : .primary)
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.xs + 2)
            .background(
                Capsule()
                    .fill(isSelected ? Color.nurseryPrimary : Color.secondary.opacity(0.15))
            )
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Card Modifier

struct NurseryCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.nurseryCard)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.07), radius: 4, x: 0, y: 2)
    }
}

extension View {
    func nurseryCard() -> some View {
        modifier(NurseryCardModifier())
    }
}

// MARK: - FAB Button Style

struct FABButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.55), value: configuration.isPressed)
    }
}

// MARK: - Avatar Gradient

extension LinearGradient {
    static let nurseryAvatar = LinearGradient(
        colors: [Color.nurseryPrimary, Color.nurseryTeal],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

