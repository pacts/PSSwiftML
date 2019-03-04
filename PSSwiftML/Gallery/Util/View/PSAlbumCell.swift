//
//  PSAlbumCell.swift
//  PSSwiftyML
//
//  Created by Aaron on 2019/1/24.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit

class PSAlbumCell: UITableViewCell {

    lazy var albumImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.image = PSGalleryBundle.image("gallery_placeholder")
        addSubview(iv)
        return iv
    }()
    
    lazy var albumTitleLabel:UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 1
        lb.font = PSGalleryConfig.Font.Text.regular.withSize(14)
        addSubview(lb)
        return lb
    }()
    
    lazy var albumCountLabel:UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 1
        lb.font = PSGalleryConfig.Font.Text.regular.withSize(10)
        addSubview(lb)
        return lb
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ album: PSAlbum) {
        albumTitleLabel.text = album.collection.localizedTitle
        albumCountLabel.text = "\(album.items.count)"

        if let item = album.items.first {
            albumImageView.layoutIfNeeded()
            albumImageView.loadImage(item.asset)
        }
    }
    
    private func setup() {
        
        albumImageView.ps_makeConstraint(attribute: .left, constant: 12)
        albumImageView.ps_makeConstraint(attribute: .top, constant: 5)
        albumImageView.ps_makeConstraint(attribute: .bottom, constant: -5)
        albumImageView.ps_makeConstraint(attribute: .width,toView: albumImageView, on: .height)
        
        albumTitleLabel.ps_makeConstraint(attribute: .top, constant: 24)
        albumTitleLabel.ps_makeConstraint(attribute: .right, constant: -10)
        albumTitleLabel.ps_makeConstraint(attribute: .left,
                                          toView: albumImageView, on: .right, constant: 10)
        
        albumCountLabel.ps_makeConstraint(attribute: .left,
                                          toView: albumImageView, on: .right, constant: 10)
        albumCountLabel.ps_makeConstraint(attribute: .top,
                                          toView: albumTitleLabel, on: .bottom, constant: 6)
    }
}
