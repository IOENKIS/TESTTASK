//
//  PhotoUploadField.swift
//  TESTTASK
//
//  Created by Ivan Kisilov on 16.05.2025.
//

import SwiftUI

struct PhotoUploadField: View {
    @Binding var image: UIImage?
    var errorMessage: String?
    private var hasError: Bool { errorMessage != nil }
    var supportingText: String? = nil

    @State private var showDialog = false
    @State private var source: UIImagePickerController.SourceType?

    @State private var showPicker = false
    @State private var showNoCameraAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            HStack {
                Text(image == nil ? "Upload your photo" : "Photo Downloaded")
                    .body1()
                    .foregroundStyle(hasError ? .error : (image == nil ? .gray.opacity(0.6) : .black))
                    .padding(.leading, 16)
                
                Spacer()
                
                Button("Upload") { showDialog = true }
                    .secondaryButton()
            }
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(
                        hasError ? Color.error : Color.gray.opacity(0.6),
                        lineWidth: 2
                    )
            )
            .confirmationDialog(
                "Choose how you want to add a photo",
                isPresented: $showDialog,
                titleVisibility: .visible
            ) {
                Button("Camera")  { if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    source = .camera
                    showPicker = true
                } else {
                    showNoCameraAlert = true
                }}
                Button("Gallery") { source = .photoLibrary; showPicker = true }
                Button("Cancel", role: .cancel) { }
            }

            .sheet(isPresented: $showPicker) {
                if let source {
                    ImagePicker(sourceType: source, selectedImage: $image)
                }
            }
            .alert("Camera not available", isPresented: $showNoCameraAlert) {
                Button("OK", role: .cancel) { }
            }
            
            let info = hasError ? errorMessage : supportingText
            let showInfo = hasError || supportingText != nil
            
            Text(info ?? " ")
                .body3()
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .frame(height: 18, alignment: .top)
                .foregroundStyle(hasError ? .error : .black.opacity(0.6))
                .opacity(showInfo ? 1 : 0)
        }
    }
}
