//
//  PDFPreviewSheet.swift
//  NurseyConnect-A2
//
//  Created by Udula on 2026-05-29.
//

import SwiftUI
import PDFKit

// MARK: - PDFKit view using UIViewController so viewDidAppear sets document with proper bounds

class PDFHostingController: UIViewController {
    let pdfView = PDFView()
    var document: PDFDocument?

    override func viewDidLoad() {
        super.viewDidLoad()
        pdfView.displayMode      = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.backgroundColor  = .systemGroupedBackground
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pdfView)
        NSLayoutConstraint.activate([
            pdfView.topAnchor.constraint(equalTo: view.topAnchor),
            pdfView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pdfView.document   = document
        pdfView.autoScales = true
    }
}

struct PDFKitView: UIViewControllerRepresentable {
    let document: PDFDocument

    func makeUIViewController(context: Context) -> PDFHostingController {
        let vc = PDFHostingController()
        vc.document = document
        return vc
    }

    func updateUIViewController(_ vc: PDFHostingController, context: Context) {}
}

// MARK: - PDF Preview Sheet

struct PDFPreviewSheet: View {
    let pdfData: Data
    let reportTitle: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            PDFKitView(document: PDFDocument(data: pdfData)!)
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle(reportTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { dismiss() }
                    }
                }
        }
    }
}
