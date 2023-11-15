//
//  PhotoSenderView.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 15.11.2023.
//

import SwiftUI
import Alamofire

struct PhotoSenderView: View {
    @State private var capturedImage: UIImage?
    @State private var isSending: Bool = false
    @State private var isCameraSheetPresented: Bool = false
    
    var isDisabled: Bool {
        capturedImage == nil || isSending
    }
    
    var body: some View {
        VStack {
            if let capturedImage = capturedImage {
                Image(uiImage: capturedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .disabled(isSending)
            } else {
                RoundedRectangle(cornerRadius: 25)
                    .frame(maxWidth: .infinity, maxHeight: Helpers.screen.height / 2)
                    .foregroundStyle(.gray)
                    .padding()
            }
            
            Button("Take a Photo") {
                isCameraSheetPresented = true
            }
            .buttonStyle(ActionButtonStyle(color: .green))
            
            
            Button("Send Photo") {
                sendPhoto(image: capturedImage!)
            }
            .buttonStyle(ActionButtonStyle(color: .green))
            .opacity(isDisabled ? 0.5 : 1)
            .disabled(isDisabled)
            
            
            
        }
        .sheet(isPresented: $isCameraSheetPresented) {
            CameraView(capturedImage: $capturedImage, isCameraShown: $isCameraSheetPresented)
        }
    }
}

extension PhotoSenderView {
    private func sendPhoto(image: UIImage) {
        withAnimation {
            isSending = true
        }
        if let imageData = image.jpegData(compressionQuality: 0.7) {
            AF.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(imageData, withName: "photo", fileName: "photo.jpg", mimeType: "image/jpeg")
            }, to: "https://smartwaste-api.azurewebsites.net/image/send")
            .validate()
            .responseDecodable(of: UploadResponse.self) { response in
                withAnimation {
                    isSending = false
                }
                
                switch response.result {
                case .success(let uploadResponse):
                    print("Photo uploaded successfully! Message: \(uploadResponse.message)")
                case .failure(let error):
                    print("Error uploading photo: \(error)")
                }
            }
        }
    }
}
