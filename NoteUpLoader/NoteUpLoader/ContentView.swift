//
//  ContentView.swift
//  NoteUpLoader
//
//  Created by William Bailey on 9/23/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showingDocPicker = false
    @State private var pickedDocs: [URL] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Button("Pick Documents") {
                    showingDocPicker = true
                }
                .buttonStyle(.borderedProminent)
                
                if pickedDocs.isEmpty {
                    Text("No documents selected")
                        .foregroundColor(.secondary)
                } else {
                    List(pickedDocs, id: \.self) { url in
                        NavigationLink(destination: PDFKitView(url: url)) {
                            Text(url.lastPathComponent)
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("NoteUpLoader")
            .sheet(isPresented: $showingDocPicker) {
                DocumentPicker { urls in
                    self.pickedDocs = urls
                }
            }
        }
    }
}

struct TestImagePickerView: View {
    @State private var isPickerPresented = false
    @State private var selectedImage: UIImage? = nil
    
    var body: some View {
        VStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
            } else {
                Text("No image selected")
                    .foregroundColor(.gray)
            }
            
            Button("Pick an Image") {
                isPickerPresented = true
            }
            .padding()
        }
        .sheet(isPresented: $isPickerPresented) {
            ImagePicker(sourceType: .photoLibrary) { image in
                selectedImage = image
            }
        }
    }
}

#Preview {
    TestImagePickerView()
}
