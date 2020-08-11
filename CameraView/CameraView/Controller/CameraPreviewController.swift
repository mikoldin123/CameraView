//
//  CameraPreviewController.swift
//  CameraView
//
//  Created by Michael Dean Villanda on 7/29/20.
//  Copyright © 2020 Michael Dean Villanda. All rights reserved.
//

import UIKit

class CameraPreviewController: UIViewController {
    
    lazy var controlsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            view.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.20)
        ])
        
        return view
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        self.controlsView.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: self.controlsView.leadingAnchor, constant: 64.0),
            button.centerYAnchor.constraint(equalTo: self.controlsView.centerYAnchor),
            button.widthAnchor.constraint(lessThanOrEqualTo: self.controlsView.widthAnchor, multiplier: 0.30)
        ])
        
        return button
    }()
    
    lazy var retakeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        self.controlsView.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: self.controlsView.trailingAnchor, constant: -64.0),
            button.centerYAnchor.constraint(equalTo: self.controlsView.centerYAnchor),
            button.widthAnchor.constraint(lessThanOrEqualTo: self.controlsView.widthAnchor, multiplier: 0.30)
        ])
        
        return button
    }()
    
    lazy var captureButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        self.controlsView.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 72.0),
            button.centerYAnchor.constraint(equalTo: self.controlsView.centerYAnchor),
            button.centerXAnchor.constraint(equalTo: self.controlsView.centerXAnchor)
        ])
        
        return button
    }()
    
    lazy var previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            imageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
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
        
        self.view.backgroundColor = .black

        controlsView.backgroundColor = UIColor.black
        
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(didCancel), for: .touchUpInside)
        
        captureButton.setImage(#imageLiteral(resourceName: "use-photo-shutter"), for: .normal)
        captureButton.addTarget(self, action: #selector(willUsePhoto), for: .touchUpInside)
        
        retakeButton.setTitle("Retake", for: .normal)
        retakeButton.addTarget(self, action: #selector(willRetake), for: .touchUpInside)
        
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
