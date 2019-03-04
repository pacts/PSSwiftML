//
//  PSGalleryPermissionView.swift
//  PSSwiftyML
//
//  Created by Aaron on 2019/1/23.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit

class PSGalleryPermissionView: UIView {

    // MARK: - Properties
    private lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = PSGalleryConfig.Permission.image
        addSubview(iv)
        return iv
    }()
    
    private lazy var label: UILabel = {
        
        let lb = UILabel()
        lb.textColor = PSGalleryConfig.Permission.textColor
        lb.font = PSGalleryConfig.Font.Text.regular.withSize(14)
        if PSGalleryPermission.Camera.needsPermission {
            lb.text = "GalleryAndCamera.Permission.Info".localized(string:  "Please grant access to photos and the camera.")
        } else {
            lb.text = "Gallery.Permission.Info".localized(string: "Please grant access to photos.")
        }
        lb.textAlignment = .center
        lb.numberOfLines = 0
        lb.lineBreakMode = .byWordWrapping
        addSubview(lb)
        return lb
    }()
    
    lazy var settingButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Gallery.Permission.Button".localized(string: "Go to Settings").uppercased(),
                        for: UIControl.State())
        btn.backgroundColor = PSGalleryConfig.Permission.Button.backgroundColor
        btn.titleLabel?.font = PSGalleryConfig.Font.Main.medium.withSize(16)
        btn.setTitleColor(PSGalleryConfig.Permission.Button.textColor, for: UIControl.State())
        btn.setTitleColor(PSGalleryConfig.Permission.Button.highlightedTextColor, for: .highlighted)
        btn.layer.cornerRadius = 22
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        addSubview(btn)
        return btn
    }()
    
    lazy var closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(PSGalleryBundle.image("gallery_close")?.withRenderingMode(.alwaysTemplate), for: UIControl.State())
        button.tintColor = PSGalleryConfig.Grid.CloseButton.tintColor
        addSubview(button)
        return button
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MAKR: - Private
    private func setup() {
        
        closeButton.ps_makeConstraint(attribute: .top,
                                      constant:SafeAreaTop())
        closeButton.ps_makeConstraint(attribute: .left,
                                      constant:5)
        closeButton.ps_makeSize(CGSize(width: 44,
                                       height: 44))
       
        settingButton.ps_makeCenter()
        settingButton.ps_makeHeight(44)
        
        label.ps_makeConstraint(attribute: .bottom,
                                toView: settingButton,
                                on: .top, constant: -24)
        label.ps_makeHorizontalPadding(padding: 50)
        
        imageView.ps_makeConstraint(attribute: .centerX)
        imageView.ps_makeConstraint(attribute: .bottom,
                                    toView: label,
                                    on: .top, constant: -16)
    }
}
