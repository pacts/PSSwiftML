//
//  PSVideoCell.swift
//  PSSwiftyML
//
//  Created by Aaron on 2019/2/3.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit

class PSVideoCell: PSImageCell {
    
    lazy var durationLabel: UILabel = {
        let lb = UILabel()
        lb.font = PSGalleryConfig.Font.Text.bold.withSize(9)
        lb.textColor = UIColor.white
        lb.textAlignment = .right
        insertSubview(lb, belowSubview: highlightOverlay)
        return lb
    }()
    
    lazy var cameraImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = PSGalleryBundle.image("gallery_video_cell_camera")
        iv.contentMode = .scaleAspectFit
        insertSubview(iv, belowSubview: highlightOverlay)
        return iv
    }()
    
    lazy var bottomOverlay: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        insertSubview(v, belowSubview: highlightOverlay)
        return v
    }()

    func configure(_ video: PSVideo) {
        super.configure(video.asset)
        
        video.fetchDuration { (duration) in
            DispatchQueue.main.async {
                self.durationLabel.text = "\(PSUtils.format(duration))"
            }
        }
    }
    
    override func setup() {
        super.setup()
        
        bottomOverlay.ps_makeDownward()
        bottomOverlay.ps_makeHeight(16)
        
        durationLabel.ps_makeConstraint(attribute: .right, constant: -4)
        durationLabel.ps_makeConstraint(attribute: .bottom, constant: -2)
        
        cameraImageView.ps_makeConstraint(attribute: .left, constant: 4)
        cameraImageView.ps_makeConstraint(attribute: .centerY, toView: durationLabel, on: .centerY)
        cameraImageView.ps_makeSize(CGSize(width: 12, height: 6))
    }
}
