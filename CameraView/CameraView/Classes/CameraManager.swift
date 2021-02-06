//
//  CameraManager.swift
//  CameraView
//
//  Created by Michael Dean Villanda on 7/29/20.
//  Copyright © 2020 Michael Dean Villanda. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

protocol CameraManagerServices {
    var flowDelegate: CameraFlowDelegate? { get set }
    var previewDelegate: CameraPreviewDelegate? { get set}
    
    var photoData: Data? { get set }
    var photoImage: UIImage? { get }
    var originalPhoto: UIImage? { get }
    
    func willRetakePhoto()
    func willUsePhoto()
    func didCancelCamera()
    
    func didCapturePhotoData(_ data: Data?)
}

protocol CameraPreviewDelegate: class {
    func cameraDidFinishCapture(_ service: CameraManagerServices)
}

protocol CameraFlowDelegate: class {
    func shoulRetakePhoto()
    func didCapturePhoto()
    func didFinishTakingPhoto()
    func willCloseCamera()
}

class CameraManager: CameraManagerServices {
    var photoData: Data?
    
    var originalPhoto: UIImage? {
        guard
            let data = photoData,
            let image = UIImage(data: data)
        else {
            return nil
        }
        
        return image
    }
    
    var photoTemporaryURL: URL? {
        return nil
    }
    
    var photoImage: UIImage? {
        guard
            let data = photoData,
            let image = UIImage(data: data),
            let cgImage = image.cgImage
        else {
            return nil
        }
        
        return UIImage(cgImage: cgImage, scale: 1.0, orientation: .right)
    }
    
    static let shared = CameraManager()
    
    weak var flowDelegate: CameraFlowDelegate?
    weak var previewDelegate: CameraPreviewDelegate?

    func willRetakePhoto() {
        self.photoData = nil
        flowDelegate?.shoulRetakePhoto()
    }
    
    func willUsePhoto() {
        previewDelegate?.cameraDidFinishCapture(self)
        
        flowDelegate?.didFinishTakingPhoto()
    }
    
    func didCancelCamera() {
        self.photoData = nil
        
        flowDelegate?.willCloseCamera()
    }
    
    func didCapturePhotoData(_ data: Data?) {
        self.photoData = data

        flowDelegate?.didCapturePhoto()
    }
}
