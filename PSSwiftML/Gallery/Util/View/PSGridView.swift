//
//  PSGridView.swift
//  PSSwiftyML
//
//  Created by Aaron on 2019/1/24.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit

class PSGridView: UIView {
    
    lazy var topView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        addSubview(v)
        return v
    }()
    
    lazy var arrow: PSArrowButton = {
        let btn = PSArrowButton()
        btn.layoutSubviews()
        topView.addSubview(btn)
        return btn
    }()
    
    lazy var closeButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(PSGalleryBundle.image("gallery_close")?.withRenderingMode(.alwaysTemplate), for: UIControl.State())
        btn.tintColor = PSGalleryConfig.Grid.CloseButton.tintColor
        topView.addSubview(btn)
        return btn
    }()
    
    lazy var bottomView: UIView = {
        let v = UIView()
        addSubview(v)
        return v
    }()
    
    lazy var bottomBlurView: UIVisualEffectView = {
        let v = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        bottomView.addSubview(v)
        return v
    }()
    
    lazy var doneButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitleColor(UIColor.white, for: UIControl.State())
        btn.setTitleColor(UIColor.lightGray, for: .disabled)
        btn.titleLabel?.font = PSGalleryConfig.Font.Text.regular.withSize(16)
        btn.setTitle("Gallery.Done".localized(string: "Done"), for: UIControl.State())
        bottomView.addSubview(btn)
        return btn
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        addSubview(cv)
        return cv
    }()
    
    lazy var emptyView: PSEmptyView = {
        let ev = PSEmptyView()
        ev.isHidden = true
        addSubview(ev)
        return ev
    }()
    
    lazy var loadingIndicator: UIActivityIndicatorView = {
        let aiv =  UIActivityIndicatorView(style: .whiteLarge)
        aiv.color = .gray
        aiv.hidesWhenStopped = true
        addSubview(aiv)
        return aiv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        loadingIndicator.startAnimating()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = .white
        collectionView.ps_makeDownward()
        collectionView.ps_makeConstraint(attribute: .top,
                                         toView: topView,
                                         on: .bottom,
                                         constant: 1)
        bottomView.ps_makeDownward()
        bottomView.ps_makeHeight(80)
        
        arrow.ps_makeCenter()
        arrow.ps_makeHeight(40)
        
        closeButton.ps_makeConstraint(attribute: .top)
        closeButton.ps_makeConstraint(attribute: .left)
        closeButton.ps_makeSize(CGSize(width: 40, height: 40))
        
        emptyView.ps_makeEdges(view: collectionView)

        Constraint.on(topView.leftAnchor.constraint(equalTo: topView.superview!.leftAnchor),
                      topView.rightAnchor.constraint(equalTo: topView.superview!.rightAnchor),
                      topView.heightAnchor.constraint(equalToConstant: 44),
                      
                      loadingIndicator.centerXAnchor.constraint(
                        equalTo: loadingIndicator.superview!.centerXAnchor),
                      loadingIndicator.centerYAnchor.constraint(
                        equalTo: loadingIndicator.superview!.centerYAnchor))
        
        if #available(iOS 11, *) {
            Constraint.on(
                topView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor)
            )
        } else {
            Constraint.on(
                topView.topAnchor.constraint(equalTo: topView.superview!.topAnchor)
            )
        }
        
        bottomBlurView.ps_makeEdges()

        doneButton.ps_makeConstraint(attribute: .centerY)
        doneButton.ps_makeConstraint(attribute: .right, constant: -38)
        
        
    }
}
