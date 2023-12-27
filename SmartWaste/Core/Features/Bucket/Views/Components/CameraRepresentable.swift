//
//  CameraRepresentable.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 15.11.2023.
//

import Foundation
import UIKit
import SwiftUI

struct CameraRepresentable: UIViewControllerRepresentable {
    var onSelected: (UIImage) -> Void
    
    typealias UIViewControllerType = UIImagePickerController
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        let viewController = UIViewControllerType()
        viewController.delegate = context.coordinator
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            viewController.sourceType = .camera
        } else {
            viewController.sourceType = .savedPhotosAlbum
        }
        
        viewController.sourceType = .savedPhotosAlbum

        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    func makeCoordinator() -> CameraRepresentable.Coordinator {
        return Coordinator(self)
    }
}

extension CameraRepresentable {
    class Coordinator : NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: CameraRepresentable
        
        init(_ parent: CameraRepresentable) {
            self.parent = parent
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            
            guard let image = info[.originalImage] as? UIImage else {
                return
            }
            parent.onSelected(image)
            picker.dismiss(animated: true)
        }
    }
}
