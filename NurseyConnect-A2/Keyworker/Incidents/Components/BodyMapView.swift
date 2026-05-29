//
//  BodyMapView.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

import SwiftUI

// MARK: - Body Silhouette Shape

/// Connected human-figure silhouette built from overlapping rounded-rect
/// segments. Segments overlap so the filled shape reads as one solid body.
/// Used for both fill and hit-testing — only taps inside this path register.
struct BodySilhouette: Shape {
    let showFront: Bool

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        func x(_ n: Double) -> CGFloat { CGFloat(n) * w }
        func y(_ n: Double) -> CGFloat { CGFloat(n) * h }
        func sz(_ nw: Double, _ nh: Double) -> CGSize { CGSize(width: x(nw), height: y(nh)) }

        // Head (overlaps neck top)
        p.addEllipse(in: CGRect(x: x(0.41), y: y(0.01), width: x(0.18), height: y(0.19)))

        // Neck (overlaps head bottom + torso top)
        p.addRoundedRect(
            in: CGRect(x: x(0.455), y: y(0.17), width: x(0.09), height: y(0.10)),
            cornerSize: sz(0.02, 0.015)
        )

        // Torso (wide, overlaps limb tops)
        p.addRoundedRect(
            in: CGRect(x: x(0.30), y: y(0.24), width: x(0.40), height: y(0.32)),
            cornerSize: sz(0.05, 0.04)
        )

        // Left upper arm
        p.addRoundedRect(
            in: CGRect(x: x(0.16), y: y(0.24), width: x(0.15), height: y(0.22)),
            cornerSize: sz(0.04, 0.03)
        )
        // Left forearm
        p.addRoundedRect(
            in: CGRect(x: x(0.13), y: y(0.44), width: x(0.13), height: y(0.21)),
            cornerSize: sz(0.04, 0.03)
        )

        // Right upper arm
        p.addRoundedRect(
            in: CGRect(x: x(0.69), y: y(0.24), width: x(0.15), height: y(0.22)),
            cornerSize: sz(0.04, 0.03)
        )
        // Right forearm
        p.addRoundedRect(
            in: CGRect(x: x(0.74), y: y(0.44), width: x(0.13), height: y(0.21)),
            cornerSize: sz(0.04, 0.03)
        )

        // Left thigh (top overlaps torso bottom)
        p.addRoundedRect(
            in: CGRect(x: x(0.31), y: y(0.53), width: x(0.17), height: y(0.24)),
            cornerSize: sz(0.04, 0.03)
        )
        // Left lower leg
        p.addRoundedRect(
            in: CGRect(x: x(0.32), y: y(0.75), width: x(0.15), height: y(0.22)),
            cornerSize: sz(0.04, 0.03)
        )

        // Right thigh
        p.addRoundedRect(
            in: CGRect(x: x(0.52), y: y(0.53), width: x(0.17), height: y(0.24)),
            cornerSize: sz(0.04, 0.03)
        )
        // Right lower leg
        p.addRoundedRect(
            in: CGRect(x: x(0.53), y: y(0.75), width: x(0.15), height: y(0.22)),
            cornerSize: sz(0.04, 0.03)
        )

        return p
    }
}

// MARK: - BodyMapView

struct BodyMapView: View {
    @Binding var marks: [BodyMapMark]
    let isEditable: Bool

    @State private var showingFront = true
    @State private var pulse = false

    private var visibleMarks: [BodyMapMark] {
        marks.filter { $0.isFrontView == showingFront }
    }

    var body: some View {
        VStack(spacing: AppSpacing.md) {

            // MARK: Front / Back toggle
            Picker("View", selection: $showingFront) {
                Text("Front").tag(true)
                Text("Back").tag(false)
            }
            .pickerStyle(.segmented)

            // MARK: Silhouette + markers
            ZStack {
                // Subtle dot-grid background
                Canvas { ctx, size in
                    let spacing: CGFloat = 20
                    var col: CGFloat = spacing
                    while col < size.width {
                        var row: CGFloat = spacing
                        while row < size.height {
                            let dot = Path(ellipseIn: CGRect(x: col - 1, y: row - 1,
                                                             width: 2, height: 2))
                            ctx.fill(dot, with: .color(Color.nurseryPrimary.opacity(0.06)))
                            row += spacing
                        }
                        col += spacing
                    }
                }

                GeometryReader { geo in
                    ZStack {
                        // Warm skin-tone fill
                        BodySilhouette(showFront: showingFront)
                            .fill(Color(red: 0.97, green: 0.90, blue: 0.84).opacity(0.85))

                        // Outline stroke
                        BodySilhouette(showFront: showingFront)
                            .stroke(Color.nurseryPrimary.opacity(0.50), lineWidth: 1.6)

                        // Zone labels
                        Canvas { ctx, size in
                            let labels: [(String, Double, Double)] = showingFront
                                ? [("Head",   0.50, 0.08),
                                   ("Torso",  0.50, 0.38),
                                   ("L Arm",  0.16, 0.37),
                                   ("R Arm",  0.84, 0.37),
                                   ("L Leg",  0.38, 0.72),
                                   ("R Leg",  0.62, 0.72)]
                                : [("Head",   0.50, 0.08),
                                   ("Back",   0.50, 0.38),
                                   ("L Arm",  0.16, 0.37),
                                   ("R Arm",  0.84, 0.37),
                                   ("L Leg",  0.38, 0.72),
                                   ("R Leg",  0.62, 0.72)]
                            for (label, nx, ny) in labels {
                                let pt = CGPoint(x: nx * size.width, y: ny * size.height)
                                ctx.draw(
                                    Text(label)
                                        .font(.system(size: 8, weight: .medium))
                                        .foregroundStyle(Color.secondary.opacity(0.65)),
                                    at: pt, anchor: .center
                                )
                            }
                        }
                        .allowsHitTesting(false)

                        // Tap / remove gesture — ONLY registers inside the silhouette
                        if isEditable {
                            Color.clear
                                .contentShape(Rectangle())
                                .gesture(
                                    DragGesture(minimumDistance: 0)
                                        .onEnded { value in
                                            let tap = value.location
                                            let frame = CGRect(origin: .zero, size: geo.size)
                                            let silhouette = BodySilhouette(showFront: showingFront)
                                                .path(in: frame)

                                            // Reject taps outside the body silhouette
                                            guard silhouette.contains(tap) else { return }

                                            let nx = tap.x / geo.size.width
                                            let ny = tap.y / geo.size.height
                                            let threshold = 0.06

                                            // Tap near existing marker → remove it
                                            if let idx = marks.firstIndex(where: {
                                                $0.isFrontView == showingFront &&
                                                abs($0.xNormalized - nx) < threshold &&
                                                abs($0.yNormalized - ny) < threshold
                                            }) {
                                                _ = withAnimation(.spring(duration: 0.2)) {
                                                    marks.remove(at: idx)
                                                }
                                            } else {
                                                // Add new marker
                                                withAnimation(.spring(duration: 0.3)) {
                                                    marks.append(BodyMapMark(
                                                        xNormalized: nx,
                                                        yNormalized: ny,
                                                        isFrontView: showingFront,
                                                        label: showingFront ? "Front" : "Back"
                                                    ))
                                                }
                                            }
                                        }
                                )
                        }

                        // Injury markers with pulse ring
                        ForEach(visibleMarks) { mark in
                            ZStack {
                                if isEditable {
                                    Circle()
                                        .fill(Color.red.opacity(0.22))
                                        .frame(width: 24, height: 24)
                                        .scaleEffect(pulse ? 1.45 : 1.0)
                                }
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 13, height: 13)
                                    .overlay(Circle().stroke(.white, lineWidth: 1.5))
                                    .shadow(color: Color.red.opacity(0.40), radius: 3)
                            }
                            .position(
                                x: mark.xNormalized * geo.size.width,
                                y: mark.yNormalized * geo.size.height
                            )
                            .allowsHitTesting(false)
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
            }
            .frame(height: isEditable ? 300 : 220)
            .background(Color.nurseryCard, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.nurseryPrimary.opacity(0.12), lineWidth: 1)
            )
            .onAppear {
                guard isEditable else { return }
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            }
            .accessibilityLabel(
                "Body map. \(isEditable ? "Tap to mark injury locations." : "") \(visibleMarks.count) marker\(visibleMarks.count == 1 ? "" : "s") on \(showingFront ? "front" : "back")."
            )

            // MARK: Footer
            if isEditable {
                if !marks.isEmpty {
                    HStack {
                        Label(
                            "\(marks.count) marker\(marks.count == 1 ? "" : "s") placed",
                            systemImage: "circle.fill"
                        )
                        .font(.caption)
                        .foregroundStyle(Color.red)
                        Spacer()
                        Button("Clear all") {
                            withAnimation { marks.removeAll() }
                        }
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.red)
                    }
                    .padding(.horizontal, AppSpacing.xs)
                } else {
                    Text("Tap the body outline to mark injury locations. Tap a marker to remove it.")
                        .font(.bodySmall)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 24) {
            Text("Editable").font(.headline)
            BodyMapView(marks: .constant([
                BodyMapMark(xNormalized: 0.50, yNormalized: 0.08, isFrontView: true, label: "Front"),
                BodyMapMark(xNormalized: 0.38, yNormalized: 0.55, isFrontView: true, label: "Front")
            ]), isEditable: true)

            Text("Read-only").font(.headline)
            BodyMapView(marks: .constant([
                BodyMapMark(xNormalized: 0.50, yNormalized: 0.08, isFrontView: true, label: "Front")
            ]), isEditable: false)
        }
        .padding()
    }
}
