//
//  ViewController.swift
//  CameraView
//
//  Created by Michael Dean Villanda on 7/29/20.
//  Copyright © 2020 Michael Dean Villanda. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    lazy var cameraButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 64.0),
            button.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            button.heightAnchor.constraint(equalToConstant: 44.0)
        ])
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        cameraButton.setImage(#imageLiteral(resourceName: "close-camera-icon"), for: .normal)
        cameraButton.addTarget(self, action: #selector(showCamera), for: .touchUpInside)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
   
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var shouldAutorotate: Bool {
        return true
    }
    
    @objc func showCamera() {
        let service = CameraManager.shared
        service.previewDelegate = self
        
        
        let cameraController = CameraViewController(manager: service)
        cameraController.modalPresentationStyle = .fullScreen
        
        let navigation = UINavigationController(rootViewController: cameraController)
        navigation.modalPresentationStyle = .fullScreen
        self.present(navigation, animated: true, completion: nil)
    }

}

extension ViewController: CameraPreviewDelegate {
    func cameraDidFinishCapture(_ service: CameraManagerServices) {
        print("DATA ------ \(service.photoData?.count)")
    }
}

extension UIImage {
    
    func fixOrientation() -> UIImage? {
        if self.imageOrientation == .up {
            return self.resizeImage(CGSize(width: 720.0, height: 1024.0))
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        
        guard let normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        
        return normalizedImage.resizeImage(CGSize(width: 720.0, height: 1024.0))
    }
}

extension UIImage {
    var isLandscape: Bool {
        if size.width > size.height {
            return true
        }
        return false
    }
    
    func resizeImage(_ targetSize: CGSize) -> UIImage {
        let size = self.size
        
        if targetSize.width > size.width {
            return self
        }
       
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        
        self.draw(in: rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let new = newImage {
            return new
        }
        return self
    }
}

