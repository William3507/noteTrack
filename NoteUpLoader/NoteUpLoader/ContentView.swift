//
//  ContentView.swift
//  NoteUpLoader
//
//  Created by William Bailey on 9/23/25.
//

import SwiftUI
import PDFKit
import Vision
import CoreImage


struct ContentView: View {
    // MARK: - Import Area
    
    @State private var showingDocPicker = false
    @State private var pickedDocs: [URL] = []
    @State private var currentPDF: URL? = nil
    
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var selectedImage: UIImage? = nil
    
    @State private var processedImage: UIImage? = nil
    
    @State private var extractedText: String = ""
    @State private var showingTextView = false

    // MARK: - Sliders preprocessing
    @State private var contrast: Double = 1.5
    @State private var sharpness: Double = 0.98
    @State private var threshold: Double = 1.0
    
    var body: some View {
        NavigationView {
            ScrollView { // 🔹 Make it scrollable
                VStack(spacing: 20) {
                    
                    // Pick Documents
                    Button("Pick Documents") {
                        showingDocPicker = true
                    }
                    .buttonStyle(.bordered)
                    
                    // Select Photo
                    Button("Select Photo") {
                        showingImagePicker = true
                    }
                    .buttonStyle(.bordered)
                    
                    // Take Photo
                    Button("Take Photo") {
                        showingCamera = true
                    }
                    .buttonStyle(.bordered)
                    
                    // Show currently selected PDF
                    if let pdfURL = currentPDF {
                        PDFKitView(url: pdfURL)
                            .frame(maxHeight: 300)
                            .padding()
                        
                        Button("Extract Text from PDF") {
                            extractedText = extractTextFromPDF(pdfURL)
                            showingTextView = true
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Text("No PDF selected")
                            .foregroundColor(.secondary)
                    }
                    
                    // Tappable list of PDFs
                    if !pickedDocs.isEmpty {
                        List(pickedDocs, id: \.self) { url in
                            Button(action: {
                                currentPDF = url
                            }) {
                                HStack {
                                    Text(url.lastPathComponent)
                                    Spacer()
                                    if currentPDF == url {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                        .frame(height: 150)
                    }
                    
                    // Show picked image
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                        
                        // 🔹 Preprocessing Sliders
                        VStack(spacing: 10) {
                            Text("Adjust Preprocessing")
                                .font(.headline)
                            
                            Slider(value: $contrast, in: 0.5...3.0, step: 0.1) {
                                Text("Contrast")
                            }
                            Text("Contrast: \(contrast, specifier: "%.2f")")
                            
                            Slider(value: $sharpness, in: 0.0...2.0, step: 0.1) {
                                Text("Sharpness")
                            }
                            Text("Sharpness: \(sharpness, specifier: "%.2f")")
                            
                            Slider(value: $threshold, in: 0.0...1.0, step: 0.05) {
                                Text("Threshold")
                            }
                            Text("Threshold: \(threshold, specifier: "%.2f")")
                            
                            Button("Reset to Defaults") { // 🔹 Reset button
                                contrast = 1.5
                                sharpness = 0.98
                                threshold = 1.0
                            }
                            .buttonStyle(.bordered)
                            .padding(.top, 5)
                        }
                        .padding()
                        
                        Button("Extract Text from Image") {
                            performOCR(on: image)
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Text("No image selected")
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Navigate to TextDisplayView
                    NavigationLink(destination: TextDisplayView(text: extractedText),
                                   isActive: $showingTextView) {
                        EmptyView()
                    }
                }
                .padding()
                .navigationTitle("NoteUpLoader")
            }
            
            // Doc picker
            .sheet(isPresented: $showingDocPicker) {
                DocumentPicker { urls in
                    self.pickedDocs = urls
                    if let first = urls.first {
                        currentPDF = first
                    }
                }
            }
            
            // Library picker
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(sourceType: .photoLibrary) { image in
                    selectedImage = image
                }
            }
            
            // Camera picker
            .sheet(isPresented: $showingCamera) {
                ImagePicker(sourceType: .camera) { image in
                    selectedImage = image
                }
            }
        }
    }
    
    // MARK: - PDF Text Extraction
    func extractTextFromPDF(_ url: URL) -> String {
        guard let document = PDFDocument(url: url) else { return "" }
        var text = ""
        for i in 0..<document.pageCount {
            if let pageText = document.page(at: i)?.string {
                text += pageText + "\n"
            }
        }
        return text
    }
    
    // MARK: - OCR
    func performOCR(on image: UIImage) {
        let processedImage = preprocessImage(image)
        
        guard let cgImage = processedImage.cgImage else { return }
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        let request = VNRecognizeTextRequest { (request, error) in
            if let observations = request.results as? [VNRecognizedTextObservation] {
                let recognized = observations.compactMap { $0.topCandidates(1).first?.string }
                DispatchQueue.main.async {
                    extractedText = recognized.joined(separator: "\n")
                    showingTextView = true
                }
            }
        }
        
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en-US"]
        request.usesLanguageCorrection = true
        
        try? requestHandler.perform([request])
    }
    
    // MARK: - Preprocess Image
    func preprocessImage(_ image: UIImage) -> UIImage {
        guard let ciImage = CIImage(image: image) else { return image }
        
        // Step 1: Increase contrast + grayscale
        let colorControls = CIFilter(name: "CIColorControls")!
        colorControls.setValue(ciImage, forKey: kCIInputImageKey)
        colorControls.setValue(contrast, forKey: kCIInputContrastKey)
        colorControls.setValue(0.0, forKey: kCIInputSaturationKey) // grayscale
        
        var output = colorControls.outputImage ?? ciImage
        
        // Step 2: Sharpen strokes
        if let sharpen = CIFilter(name: "CISharpenLuminance") {
            sharpen.setValue(output, forKey: kCIInputImageKey)
            sharpen.setValue(sharpness, forKey: kCIInputSharpnessKey)
            output = sharpen.outputImage ?? output
        }
        
        // Step 3: Threshold (simulate binarization)
        if let thresholdFilter = CIFilter(name: "CIColorClamp") {
            thresholdFilter.setValue(output, forKey: kCIInputImageKey)
            thresholdFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputMinComponents")
            thresholdFilter.setValue(CIVector(x: threshold, y: threshold, z: threshold, w: 1),
                                     forKey: "inputMaxComponents")
            output = thresholdFilter.outputImage ?? output
        }
        
        let context = CIContext()
        if let cgImage = context.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cgImage)
        }
        return image
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
    ContentView()
}
