//
//  PSVideoBox.swift
//  PSSwiftyML
//
//  Created by Aaron on 2019/2/3.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit

protocol PSVideoBoxDelegate: class {
    func videoBoxDidTap(_ videoBox: PSVideoBox)
}

class PSVideoBox: UIView {

    lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        addSubview(iv)
        return iv
    }()
    
    lazy var cameraImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = PSGalleryBundle.image("gallery_video_cell_camera")
        addSubview(iv)
        return iv
    }()
    
    weak var delegate: PSVideoBoxDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = .clear
        imageView.addRoundBorder()
        
        let tgr = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
        addGestureRecognizer(tgr)
        
        imageView.ps_makeEdges()
        cameraImageView.ps_makeConstraint(attribute: .left, constant: 5)
        cameraImageView.ps_makeConstraint(attribute: .bottom, constant: -5)
        cameraImageView.ps_makeSize(CGSize(width: 12, height: 6))
    }
    
    @objc func viewTapped(_ gr: UITapGestureRecognizer) {
        delegate?.videoBoxDidTap(self)
    }
}
