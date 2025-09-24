//
//  DocumentPicker.swift
//  NoteUpLoader
//
//  Created by William Bailey on 9/23/25.
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct DocumentPicker: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIDocumentPickerViewController
    
    @Environment(\.presentationMode) var presentationMode
    var allowedTypes: [UTType] = [.pdf] // Default to PDFs
    var onDocumentsPicked: ([URL]) -> Void // Multiple URLs back to parent
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: allowedTypes)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = true // multiple selection
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            var copiedURLs: [URL] = []
            
            for url in urls {
                if url.startAccessingSecurityScopedResource() {
                    defer { url.stopAccessingSecurityScopedResource() }
                    
                    do {
                        let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let destURL = docsDir.appendingPathComponent(url.lastPathComponent)
                        
                        // If file already exists, remove and replace it
                        if FileManager.default.fileExists(atPath: destURL.path) {
                            try FileManager.default.removeItem(at: destURL)
                        }
                        
                        try FileManager.default.copyItem(at: url, to: destURL)
                        copiedURLs.append(destURL)
                        
                    } catch {
                        print("Error copying file: \(error.localizedDescription)")
                    }
                } else {
                    print("Could not access security-scoped resource.")
                }
            }
            
            parent.onDocumentsPicked(copiedURLs)
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
