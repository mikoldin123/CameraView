//
//  CameraFrame.swift
//  CameraView
//
//  Created by Michael Dean Villanda on 2/6/21.
//  Copyright © 2021 Michael Dean Villanda. All rights reserved.
//

import UIKit

class CameraFrame: UIView {
    lazy var cameraSquare: CameraSquare = {
        let imageView = CameraSquare()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: self.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        cameraSquare.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        cameraSquare.layer.borderWidth = 3.0
        cameraSquare.layer.cornerRadius = 8.0
        cameraSquare.layer.borderColor = UIColor.blue.cgColor
    }
}
