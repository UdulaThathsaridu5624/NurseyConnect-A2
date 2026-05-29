//
//  IncidentStep3BodyMap.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

import SwiftUI

struct IncidentStep3BodyMap: View {
    @Binding var draft: IncidentReportDraft

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.md) {

                // Info banner
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(Color.nurseryPrimary)
                    Text("Optional — tap the body diagram to mark where the injury occurred. This step can be skipped.")
                        .font(.bodySmall)
                        .foregroundStyle(.secondary)
                }
                .padding(AppSpacing.md)
                .background(Color.nurseryPrimary.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, AppSpacing.md)
                .padding(.top, AppSpacing.md)

                BodyMapView(marks: $draft.bodyMapMarks, isEditable: true)
            }
        }
    }
}

#Preview {
    IncidentStep3BodyMap(draft: .constant(IncidentReportDraft()))
}
