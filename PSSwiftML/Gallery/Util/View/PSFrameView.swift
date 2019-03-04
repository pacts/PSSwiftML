//
//  PSFrameView.swift
//  PSSwiftyML
//
//  Created by Aaron on 2019/1/24.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit

class PSFrameView: UIView {

    lazy var label: UILabel = {
        let lb = UILabel()
        lb.font = PSGalleryConfig.Font.Main.regular.withSize(40)
        lb.textColor = UIColor.white
        addSubview(lb)
        return lb
    }()

    lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
        PSGalleryConfig.Grid.FrameView.fillColor.withAlphaComponent(0.25).cgColor, PSGalleryConfig.Grid.FrameView.fillColor.withAlphaComponent(0.4).cgColor
        ]
        self.layer.addSublayer(layer)
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    private func setup() {
        layer.borderColor = PSGalleryConfig.Grid.FrameView.borderColor.cgColor
        layer.borderWidth = 3
        label.ps_makeCenter()
    }
}
