//
//  PSEmptyView.swift
//  PSSwiftyML
//
//  Created by Aaron on 2019/1/24.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit

class PSEmptyView: UIView {

    lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = PSGalleryConfig.EmptyView.image
        addSubview(iv)
        return iv
    }()

    lazy var label: UILabel = {
        let lb = UILabel()
        lb.textColor = PSGalleryConfig.EmptyView.textColor
        lb.font = PSGalleryConfig.Font.Text.regular.withSize(14)
        lb.text = "Gallery.EmptyView.Text".localized(string: "Nothing to show")
        addSubview(lb)
        return lb
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        label.ps_makeCenter()
        imageView.ps_makeConstraint(attribute: .centerX)
        imageView.ps_makeConstraint(attribute: .bottom, toView: label, on: .top, constant: -12)
    }
}


