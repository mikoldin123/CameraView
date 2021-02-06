//
//  CameraPreviewController.swift
//  CameraView
//
//  Created by Michael Dean Villanda on 7/29/20.
//  Copyright © 2020 Michael Dean Villanda. All rights reserved.
//

import UIKit

class CameraPreviewController: UIViewController {
    lazy var previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16.0),
            imageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16.0),
            imageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 16.0),
            imageView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -16.0)
        ])
        
        return imageView
    }()
    
    var cameraMngr: CameraManagerServices?
    
    convenience init(manager: CameraManagerServices) {
        self.init()
        self.cameraMngr = manager
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .darkGray
        
        previewImageView.contentMode = .scaleAspectFit
        previewImageView.image = cameraMngr?.photoImage
    }

    @objc
    func willRetake() {
        cameraMngr?.willRetakePhoto()
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc
    func didCancel() {
        self.dismiss(animated: false) { [weak self] in
            guard let this = self else { return }
            this.cameraMngr?.didCancelCamera()
        }
    }
    
    @objc
    func willUsePhoto() {
        self.dismiss(animated: false) { [weak self] in
            guard let this = self else { return }
            this.cameraMngr?.willUsePhoto()
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var shouldAutorotate: Bool {
        return true
    }
}
