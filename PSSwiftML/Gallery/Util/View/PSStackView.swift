//
//  PSStackView.swift
//  PSSwiftyML
//
//  Created by Aaron on 2019/1/28.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit
import Photos

class PSStackView: UIControl {

    lazy var indicator: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView()
        aiv.alpha = 0
        addSubview(aiv)
        return aiv
    }()
    
    lazy var imageViews: [UIImageView] = {
    
        return Array(0..<PSGalleryConfig.Camera.StackView.imageCount).map { _ in
            let iv = UIImageView()
            iv.contentMode = .scaleAspectFill
            iv.alpha = 0
            iv.addRoundBorder()
            addSubview(iv)
            return iv
        }
    }()
    
    lazy var countLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = UIColor.white
        lb.font = PSGalleryConfig.Font.Main.regular.withSize(20)
        lb.textAlignment = .center
        lb.addShadow()
        lb.alpha = 0
        addSubview(lb)
        return lb
    }()
    
    lazy var tapGR: UITapGestureRecognizer = {
        let gr = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
        addGestureRecognizer(gr)
        return gr
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let step: CGFloat = 3.0
        let scale: CGFloat = 0.8
        let imageViewSize = CGSize(width: frame.width * scale,
                                   height: frame.height * scale)
        
        for (index, imageView) in imageViews.enumerated() {
            let origin = CGPoint(x: CGFloat(index) * step,
                                 y: CGFloat(imageViews.count - index) * step)
            imageView.frame = CGRect(origin: origin, size: imageViewSize)
        }
    }
    
    // MARK: - Action
    
    @objc func viewTapped(_ gr: UITapGestureRecognizer) {
        sendActions(for: .touchUpInside)
    }
    
    // MARK: - Logic
    
    func startLoading() {
        if let topVisibleView = imageViews.filter({ $0.alpha == 1.0 }).last {
            indicator.center = topVisibleView.center
        } else if let first = imageViews.first {
            indicator.center = first.center
        }
        
        indicator.startAnimating()
        UIView.animate(withDuration: 0.3, animations: {
            self.indicator.alpha = 1.0
        })
    }
    
    func stopLoading() {
        indicator.stopAnimating()
        indicator.alpha = 0
    }
    
    func renderViews(_ assets: [PHAsset]) {
        let photos = Array(assets.suffix(PSGalleryConfig.Camera.StackView.imageCount))
        
        for (index, view) in imageViews.enumerated() {
            if index < photos.count {
                view.loadImage(photos[index])
                view.alpha = 1
            } else {
                view.image = nil
                view.alpha = 0
            }
        }
    }
    
    fileprivate func animate(imageView: UIImageView) {
        imageView.transform = CGAffineTransform(scaleX: 0, y: 0)
        
        UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: [], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.6) {
                imageView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.4) {
                imageView.transform = CGAffineTransform.identity
            }
            
        }, completion: { finished in
            
        })
    }
    
    // MARK: - Reload
    
    func reload(_ images: [PSImage], added: Bool = false) {
        // Animate empty view
        if added {
            if let emptyView = imageViews.filter({ $0.image == nil }).first {
                animate(imageView: emptyView)
            }
        }
        
        // Update images into views
        renderViews(images.map { $0.asset })
        
        // Update count label
        if let topVisibleView = imageViews.filter({ $0.alpha == 1.0 }).last , images.count > 1 {
            countLabel.text = "\(images.count)"
            countLabel.sizeToFit()
            countLabel.center = topVisibleView.center
            countLabel.quickFade()
        } else {
            countLabel.alpha = 0
        }
    }

}
