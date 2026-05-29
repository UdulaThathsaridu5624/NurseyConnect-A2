//
//  PDFPreviewSheet.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

import SwiftUI
import PDFKit

struct PDFKitView: UIViewRepresentable {
    let data: Data

    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.autoScales       = true
        view.displayMode      = .singlePageContinuous
        view.displayDirection = .vertical
        return view
    }

    func updateUIView(_ view: PDFView, context: Context) {
        view.document = PDFDocument(data: data)
    }
}

struct PDFPreviewSheet: View {
    let pdfData: Data
    let reportTitle: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            PDFKitView(data: pdfData)
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle(reportTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { dismiss() }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        ShareLink(
                            item: pdfData,
                            preview: SharePreview(reportTitle, image: Image(systemName: "doc.fill"))
                        )
                    }
                }
        }
    }
}
