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
    lazy var controlsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            view.heightAnchor.constraint(equalToConstant: 180.0),
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
        
        return view
    }()
    
    fileprivate lazy var instructionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        self.controlsView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: self.controlsView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: self.controlsView.trailingAnchor),
            label.topAnchor.constraint(equalTo: self.controlsView.topAnchor, constant: 16.0)
        ])
        
        return label
    }()
    
    lazy var captureButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        self.controlsView.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: self.instructionLabel.bottomAnchor, constant: 16.0),
            button.heightAnchor.constraint(equalToConstant: 80.0),
            button.centerXAnchor.constraint(equalTo: self.controlsView.centerXAnchor)
        ])
        
        return button
    }()

    lazy var cameraImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.controlsView.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        return imageView
    }()
    
    lazy var camera: CameraServices = {
        return Camera()
    }()
    
    fileprivate lazy var cameraSquare: CameraFrame = {
        let square = CameraFrame()
        square.translatesAutoresizingMaskIntoConstraints = false
        self.cameraImageView.addSubview(square)
        
        NSLayoutConstraint.activate([
            square.leadingAnchor.constraint(equalTo: self.cameraImageView.leadingAnchor, constant: 16.0),
            square.trailingAnchor.constraint(equalTo: self.cameraImageView.trailingAnchor, constant: -16.0),
            square.heightAnchor.constraint(equalTo: self.cameraImageView.heightAnchor, multiplier: 0.45),
            square.centerYAnchor.constraint(equalTo: self.cameraImageView.centerYAnchor, constant: -24.0)
        ])
        
        return square
    }()
    
    fileprivate lazy var captureInstructionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        self.cameraImageView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: self.cameraImageView.leadingAnchor, constant: 16.0),
            label.trailingAnchor.constraint(equalTo: self.cameraImageView.trailingAnchor, constant: -16.0),
            label.bottomAnchor.constraint(equalTo: self.cameraSquare.topAnchor, constant: -16.0)
        ])
        
        return label
    }()
    
    var instructions: String = "" {
        didSet {
            let strokeTextAttributes: [NSAttributedString.Key : Any] = [.strokeColor : UIColor.black, .foregroundColor : UIColor.white, .strokeWidth : -2.0]
            instructionLabel.attributedText = NSAttributedString(string: instructions, attributes: strokeTextAttributes)
        }
    }
    
    var captureInstructions: String = "" {
        didSet {
            let strokeTextAttributes: [NSAttributedString.Key : Any] = [.strokeColor : UIColor.black, .foregroundColor : UIColor.white, .strokeWidth : -2.0]
            captureInstructionLabel.attributedText = NSAttributedString(string: captureInstructions, attributes: strokeTextAttributes)
        }
    }
    
    var cameraMngr: CameraManagerServices?
    
    var showCaptureSquare: Bool = true {
        didSet {
            cameraSquare.isHidden = !showCaptureSquare
        }
    }
    
    convenience init(manager: CameraManagerServices) {
        self.init()
        self.cameraMngr = manager
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Take Photo"
        if #available(iOS 13.0, *) {
            navigationController?.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeCamera))
        } else {
            // Fallback on earlier versions
        }
        
        cameraImageView.backgroundColor = .black
    
        controlsView.backgroundColor = .black
        
        camera.configure()
        camera.session.startRunning()
     
        instructions = "Place your ID within the frame and take a picture"
        
        captureButton.setImage(#imageLiteral(resourceName: "shutter-icon"), for: .normal)
        captureButton.addTarget(self, action: #selector(willCapturePhoto), for: .touchUpInside)
        
        cameraMngr?.flowDelegate = self
        
        cameraSquare.backgroundColor = .clear

        captureInstructions = "Front of ID"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var layerRect = self.cameraImageView.frame
        layerRect.origin.x = 0
        layerRect.origin.y = 0
  
        camera.outputRect = showCaptureSquare ? cameraSquare.frame: cameraImageView.frame

        camera.previewLayer.bounds = layerRect
        camera.previewLayer.position = CGPoint(x: layerRect.midX, y: layerRect.midY)
        self.cameraImageView.layer.addSublayer(camera.previewLayer)
        
        self.view.sendSubviewToBack(self.cameraImageView)
        
        cameraImageView.bringSubviewToFront(cameraSquare)
        cameraImageView.bringSubviewToFront(captureInstructionLabel)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var shouldAutorotate: Bool {
        return false
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
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
        self.navigationController?.pushViewController(preview, animated: true)
    }
    
    func willCloseCamera() {
        camera.destroyCamera()
        self.dismiss(animated: true, completion: nil)
    }
}
