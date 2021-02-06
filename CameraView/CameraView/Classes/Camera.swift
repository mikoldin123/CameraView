//
//  Camera.swift
//  CameraView
//
//  Created by Michael Dean Villanda on 7/29/20.
//  Copyright © 2020 Michael Dean Villanda. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

extension UIDeviceOrientation {
    
    var captureOrientation: AVCaptureVideoOrientation {
        switch self {
        case .landscapeLeft:
            return AVCaptureVideoOrientation.landscapeLeft
        case .landscapeRight:
            return AVCaptureVideoOrientation.landscapeLeft
        default:
            return .portrait
        }
    }
}

protocol CameraServices: class {
    var session: AVCaptureSession { get set }
    var previewLayer: AVCaptureVideoPreviewLayer { get set }
    
    var outputRect: CGRect? { get set }
    
    func configure()
    func capturePhoto()
    func retakePhoto()
    func destroyCamera()
}

class Camera: NSObject, CameraServices {
    
    lazy var session: AVCaptureSession = {
        
        let session = AVCaptureSession()
        session.sessionPreset = .photo
        return session
    }()
    
    lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        
        let preview =  AVCaptureVideoPreviewLayer(session: self.session)
        preview.videoGravity = .resizeAspectFill
        preview.connection?.videoOrientation = .portrait

        return preview
    }()
    
    lazy var photoOutput: AVCapturePhotoOutput = {
        return AVCapturePhotoOutput()
    }()
    
    var outputRect: CGRect?
    
    var services: CameraManagerServices {
        return CameraManager.shared
    }
    
    func configure() {
        if let device = AVCaptureDevice.default(for: .video) {
            
            do {
                
                let deviceInput = try AVCaptureDeviceInput(device: device)
                session.beginConfiguration()
                
                if session.canAddInput(deviceInput) {
                    session.addInput(deviceInput)
                }
                
                session.commitConfiguration()
                
            } catch {
                print(error)
            }
        }

        if let avConnection: AVCaptureConnection = photoOutput.connection(with: .video) {
            avConnection.videoOrientation = .portrait
        }
        
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
        
        session.canSetSessionPreset(.photo)
    }

    func capturePhoto() {
        let photoSettings = AVCapturePhotoSettings()
        //        photoSettings.isHighResolutionPhotoEnabled = true

        if let firstAvailablePreviewPhotoPixelFormatTypes = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: firstAvailablePreviewPhotoPixelFormatTypes]
        }

        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    func retakePhoto() {
        session.startRunning()
    }
    
    func destroyCamera() {
        if session.isRunning {
            session.stopRunning()
        }
        
        session.inputs.forEach { (input) in
            session.removeInput(input)
        }
        
        session.outputs.forEach { (output) in
            session.removeOutput(output)
        }
    }
    
    private func cropToPreviewLayer(originalImage: UIImage, withBoundingRect rect: CGRect) -> UIImage {
        let outputRect = previewLayer.metadataOutputRectConverted(fromLayerRect: rect)
        
        guard let cgImage = originalImage.cgImage else {
            return originalImage
        }
        
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        let cropRect = CGRect(x: outputRect.origin.x * width, y: outputRect.origin.y * height, width: outputRect.size.width * width, height: outputRect.size.height * height)

        guard let finalImage = cgImage.cropping(to: cropRect) else {
            return originalImage
        }
        
        let croppedUIImage = UIImage(cgImage: finalImage, scale: 1.0, orientation: originalImage.imageOrientation)

        return croppedUIImage
    }
}

extension Camera: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard
            let dataPhoto = photo.fileDataRepresentation(),
            let cgImage = UIImage(data: dataPhoto),
            let boundingRect = self.outputRect
        else {
            return
        }
        
        let newImage = cropToPreviewLayer(originalImage: cgImage, withBoundingRect: boundingRect)
        
        services.didCapturePhotoData(newImage.pngData())
        session.stopRunning()
    }
    
}
