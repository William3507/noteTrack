//
//  TextDisplayView.swift
//  NoteUpLoader
//
//  Created by William Bailey on 9/25/25.
//

import SwiftUI

struct TextDisplayView: View {
    let text: String
    
    var body: some View {
        ScrollView {
            Text(text)
                .padding()
        }
        .navigationTitle("Extracted Text")
    }
}


