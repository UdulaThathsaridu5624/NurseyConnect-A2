//
//  RoleSelectionView.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

import SwiftUI

enum AppRole: String {
    case keyworker = "Keyworker"
    case manager   = "Setting Manager"
}

struct RoleSelectionView: View {
    @State private var activeRole: AppRole? = nil

    var body: some View {
        // Render roles directly — not inside a sheet/cover so NavigationSplitView gets full sizing
        if activeRole == .keyworker {
            KeyworkerRootView(onChangeRole: { activeRole = nil })
        } else if activeRole == .manager {
            ManagerRootView(onChangeRole: { activeRole = nil })
        } else {
            selectionScreen
        }
    }

    private var selectionScreen: some View {
        ZStack {
            LinearGradient(
                colors: [Color.nurseryPrimary.opacity(0.15), Color.nurseryTeal.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: AppSpacing.xl) {
                VStack(spacing: AppSpacing.sm) {
                    Image(systemName: "building.2.crop.circle.fill")
                        .font(.system(size: 72))
                        .foregroundStyle(LinearGradient.nurseryAvatar)
                    Text("NurseyConnect")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .foregroundStyle(Color.nurseryPrimary)
                    Text("Little Stars Nursery & Daycare")
                        .font(.bodySmall)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, AppSpacing.lg)

                VStack(spacing: AppSpacing.md) {
                    Text("Select your role to continue")
                        .font(.sectionHead)
                        .foregroundStyle(.secondary)

                    RoleCard(
                        role: .keyworker,
                        icon: "person.fill",
                        subtitle: "Record daily diaries & incident reports",
                        color: .nurseryPrimary
                    ) { activeRole = .keyworker }

                    RoleCard(
                        role: .manager,
                        icon: "building.2.fill",
                        subtitle: "Room oversight, analytics & reports",
                        color: .nurseryTeal
                    ) { activeRole = .manager }
                }
                .padding(.horizontal, AppSpacing.lg)
            }
        }
    }
}

// MARK: - Role Card Component

private struct RoleCard: View {
    let role: AppRole
    let icon: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.md) {
                // Icon circle
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 56, height: 56)
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(color)
                }

                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(role.rawValue)
                        .font(.displayName)
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.bodySmall)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.callout)
                    .foregroundStyle(.tertiary)
            }
            .padding(AppSpacing.md)
            .nurseryCard()
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.25), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded   { _ in isPressed = false }
        )
    }
}

#Preview {
    RoleSelectionView()
}

