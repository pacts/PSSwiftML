//
//  PSShutterButton.swift
//  PSSwiftyML
//
//  Created by Aaron on 2019/1/29.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit

class PSShutterButton: UIButton {

    // MARK: - Properties
    lazy var overlayView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.isUserInteractionEnabled = false
        addSubview(v)
        return v
    }()
    
    lazy var roundLayer: CAShapeLayer = {
        let lyr = CAShapeLayer()
        lyr.strokeColor = PSGalleryConfig.Camera.ShutterButton.numberColor.cgColor
        lyr.lineWidth = 2
        lyr.fillColor = nil
        layer.addSublayer(lyr)
        return lyr
    }()
    
    // MARK: - Highlight
    
    override var isHighlighted: Bool {
        didSet {
            overlayView.backgroundColor = isHighlighted ? UIColor.gray : UIColor.white
        }
    }
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        overlayView.frame = bounds.insetBy(dx: 3, dy: 3)
        overlayView.layer.cornerRadius = overlayView.w / 2
        roundLayer.path = UIBezierPath(ovalIn: bounds.insetBy(dx: 3, dy: 3)).cgPath
        layer.cornerRadius = w/2
    }

}
