//
//  CameraViewController.swift
//  CameraView
//
//  Created by Michael Dean Villanda on 7/29/20.
//  Copyright © 2020 Michael Dean Villanda. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    lazy var cameraImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        return imageView
    }()
    
    lazy var controlsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view)
        
        var trailing = view.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
        trailing.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.cameraImageView.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.cameraImageView.bottomAnchor),
            trailing,
            view.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.20)
        ])
        
        return view
    }()
    
    lazy var captureButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        self.controlsView.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: self.controlsView.topAnchor, constant: 64.0),
            button.heightAnchor.constraint(equalToConstant: 80.0),
            button.centerXAnchor.constraint(equalTo: self.controlsView.centerXAnchor)
        ])
        
        return button
    }()
    
    lazy var closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        self.controlsView.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.bottomAnchor.constraint(equalTo: self.controlsView.bottomAnchor, constant: -64.0),
            button.heightAnchor.constraint(equalToConstant: 44.0),
            button.centerXAnchor.constraint(equalTo: self.controlsView.centerXAnchor)
        ])
        
        return button
    }()
    
    lazy var camera: CameraServices = {
        return Camera()
    }()
    
    fileprivate lazy var cameraSquare: CameraSquare = {
        let square = CameraSquare()
        square.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(square)
        
        NSLayoutConstraint.activate([
            square.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 32.0),
            square.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 32.0),
            square.trailingAnchor.constraint(equalTo: self.controlsView.leadingAnchor, constant: -32.0)
        ])
        
        return square
    }()
    
    fileprivate lazy var instructionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        self.view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: self.cameraSquare.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: self.cameraSquare.trailingAnchor),
            label.topAnchor.constraint(equalTo: self.cameraSquare.bottomAnchor, constant: 16.0),
            label.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -24.0)
        ])
        
        
        return label
    }()
    
    var instructions: String = "" {
        didSet {
            let strokeTextAttributes: [NSAttributedString.Key : Any] = [.strokeColor : UIColor.black, .foregroundColor : UIColor.white, .strokeWidth : -2.0]
            instructionLabel.attributedText = NSAttributedString(string: instructions, attributes: strokeTextAttributes)
        }
    }
    
    var cameraMngr: CameraManagerServices?
    
    convenience init(manager: CameraManagerServices) {
        self.init()
        self.cameraMngr = manager
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraImageView.backgroundColor = .black
        controlsView.alpha = 0.80
        controlsView.backgroundColor = .black
        
        camera.configure()
        camera.session.startRunning()
     
        instructions = "Please place your passport inside the outline above"
        
        captureButton.setImage(#imageLiteral(resourceName: "shutter-icon"), for: .normal)
        captureButton.addTarget(self, action: #selector(willCapturePhoto), for: .touchUpInside)
        
        closeButton.setImage(#imageLiteral(resourceName: "close-camera-icon"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeCamera), for: .touchUpInside)
        
        cameraMngr?.flowDelegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var layerRect = self.cameraImageView.frame
        layerRect.origin.x = 0
        layerRect.origin.y = 0
        
        camera.outputRect = cameraSquare.frame
        
        
        camera.previewLayer.bounds = layerRect
        camera.previewLayer.position = CGPoint(x: layerRect.midX, y: layerRect.midY)
        self.cameraImageView.layer.addSublayer(camera.previewLayer)
        
        self.view.sendSubviewToBack(self.cameraImageView)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }

    override var shouldAutorotate: Bool {
        return false
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }
}

@objc extension CameraViewController {
    func willCapturePhoto() {
        captureButton.isSelected = true
        camera.capturePhoto()
    }
    
    func closeCamera() {
        self.willCloseCamera()
    }
}

// MARK: - CameraFlowDelegate
extension CameraViewController: CameraFlowDelegate {
    func shoulRetakePhoto() {
        camera.retakePhoto()
    }
    
    func didFinishTakingPhoto() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func didCapturePhoto() {
        guard let service = cameraMngr else {
            return
        }
        
        let preview = CameraPreviewController(manager: service)
        preview.modalPresentationStyle = .fullScreen
        self.present(preview, animated: false, completion: nil)
    }
    
    func willCloseCamera() {
        camera.destroyCamera()
        self.dismiss(animated: true, completion: nil)
    }
}
