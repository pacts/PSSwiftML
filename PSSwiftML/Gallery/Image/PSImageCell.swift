//
//  PSImageCell.swift
//  PSSwiftyML
//
//  Created by Aaron on 2019/1/28.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit
import Photos

class PSImageCell: UICollectionViewCell {
    
    lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        contentView.addSubview(iv)
        return iv
    }()
    
    lazy var highlightOverlay: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        v.backgroundColor = PSGalleryConfig.Grid.FrameView.borderColor.withAlphaComponent(0.3)
        v.isHidden = true
        contentView.addSubview(v)
        return v
    }()
    
    lazy var frameView: PSFrameView = {
        let fv = PSFrameView(frame: .zero)
        fv.alpha = 0
        contentView.addSubview(fv)
        return fv
    }()

    lazy var masView: UIView? = {
        let mas = UIView(frame: bounds)
        mas.backgroundColor = UIColor.white
        mas.alpha = 0.6
        contentView.addSubview(mas)
        return mas
    }()
    
    override var isHighlighted: Bool {
        didSet {
            highlightOverlay.isHidden = !isHighlighted
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        
        imageView.ps_makeEdges()
        frameView.ps_makeEdges()
        highlightOverlay.ps_makeEdges()
        
    }
    
    func configure(_ asset: PHAsset) {
        imageView.layoutIfNeeded()
        imageView.loadImage(asset)
    }
    
    func configure(_ image: PSImage) {
        imageView.layoutIfNeeded()
        imageView.loadImage(image.asset)
    }
}
