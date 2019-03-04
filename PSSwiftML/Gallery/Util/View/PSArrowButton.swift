//
//  PSArrowButton.swift
//  PSSwiftyML
//
//  Created by Aaron on 2019/1/24.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit

class PSArrowButton: UIButton {

    lazy var label: UILabel = {
        let lb = UILabel()
        lb.textColor = PSGalleryConfig.Grid.ArrowButton.tintColor
        lb.font = PSGalleryConfig.Font.Main.medium
        lb.textAlignment = .center
        addSubview(lb)
        return lb
    }()
    lazy var arrow: UIImageView = {
        let iv = UIImageView()
        iv.image = PSGalleryBundle.image("gallery_title_arrow")?.withRenderingMode(.alwaysTemplate)
        iv.tintColor = PSGalleryConfig.Grid.ArrowButton.tintColor
        iv.alpha = 0
        addSubview(iv)
        return iv
    }()
    
    let padding: CGFloat = 10
    let arrowSize: CGFloat = 6
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        
        label.sizeToFit()
        return CGSize(width: label.frame.size.width + arrowSize*2 + padding,
                      height: size.height)
    }
    
    override var isHighlighted: Bool {
        didSet {
            label.textColor = isHighlighted ? UIColor.lightGray : PSGalleryConfig.Grid.ArrowButton.tintColor
            arrow.tintColor = isHighlighted ? UIColor.lightGray : PSGalleryConfig.Grid.ArrowButton.tintColor
        }
    }
    
    init() {
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        label.center = CGPoint(x: w/2, y: h/2)
        arrow.size = CGSize(width: 2*arrowSize, height: arrowSize)
        arrow.center = CGPoint(x: label.frame.maxX + padding, y: h / 2)
    }
    
    func updateText(_ text: String) {
        label.text = text.uppercased()
        arrow.alpha = text.isEmpty ? 0 : 1
        invalidateIntrinsicContentSize()
    }
    
    func toggle(_ expanding: Bool) {
        let transform = expanding
            ? CGAffineTransform(rotationAngle: CGFloat(Double.pi)) : CGAffineTransform.identity
        UIView.animate(withDuration: 0.25, animations: {
            self.arrow.transform = transform
        })
    }
    
}
