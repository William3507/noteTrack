//
//  PDFKitView.swift
//  NoteUpLoader
//
//  Created by William Bailey on 9/23/25.
//

import SwiftUI
import PDFKit

struct PDFKitView: UIViewRepresentable {
    let url : URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        
        //Display Settings (can change these if I want)
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.backgroundColor = .secondarySystemBackground
        
        
        //Error checking so we don't mess up later
        if let document = PDFDocument(url:url) {
            pdfView.document = document
        }
        else {
            print("Could not load PDF at \(url)")
        }
        
        return pdfView
    }
    
    func updateUIView(_ pdfView: PDFView, context: Context) {
        if let document = PDFDocument(url : url){
            pdfView.document = document
        }
    }
    
}
