//
//  PSPhotoController.swift
//  PSSwiftyML
//
//  Created by Aaron on 2019/1/28.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit
import Photos

class PSPhotoController: UIViewController {

    lazy var dropdownController: PSDropdownController = {
        let controller = PSDropdownController()
        controller.delegate = self
        
        return controller
    }()
    
    lazy var gridView: PSGridView = {
        let gv = PSGridView()
        gv.bottomView.alpha = 0
        gv.collectionView.dataSource = self
        gv.collectionView.delegate = self
        gv.collectionView.register(PSImageCell.self, forCellWithReuseIdentifier: String(describing: PSImageCell.self))
        view.addSubview(gv)
        return gv
    }()
    
    lazy var stackView: PSStackView = {
        let sv = PSStackView()
        gridView.bottomView.addSubview(sv)
        return sv
    }()
    
    var items: [PSImage] = []
    let library = PSPhotoLibrary()
    var selectedAlbum: PSAlbum?
    let once = PSOnce()
    let cart: PSCart
    
    public required init(cart: PSCart) {
        self.cart = cart
        super.init(nibName: nil, bundle: nil)
        cart.delegates.add(self)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view.
    }
    
    func setup() {
        view.backgroundColor = UIColor.white
        
        gridView.ps_makeEdges()
        
        addChild(dropdownController)
        gridView.insertSubview(dropdownController.view, belowSubview: gridView.topView)
        
        dropdownController.didMove(toParent: self)
        
        
        dropdownController.view.ps_makeConstraint(attribute: .left)
        dropdownController.view.ps_makeConstraint(attribute: .right)
        dropdownController.view.ps_makeConstraint(attribute: .height, constant: -40) // subtract gridView.topView height
        
        dropdownController.expandedTopConstraint = dropdownController.view.ps_makeConstraint(attribute: .top,
                                                      toView: gridView.topView,
                                                      on: .bottom,
                                                      constant: 1)
        dropdownController.expandedTopConstraint?.isActive = false
        dropdownController.collapsedTopConstraint = dropdownController.view.ps_makeConstraint(attribute: .top,
                                                      on: .bottom)
        
        stackView.ps_makeConstraint(attribute: .centerY, constant: -4)
        stackView.ps_makeConstraint(attribute: .left, constant: 38)
        stackView.ps_makeSize(CGSize(width: 56, height: 56))
        
        gridView.closeButton.addTarget(self, action: #selector(closeButtonTouched(_:)), for: .touchUpInside)
        gridView.doneButton.addTarget(self, action: #selector(doneButtonTouched(_:)), for: .touchUpInside)
        gridView.arrow.addTarget(self, action: #selector(arrowButtonTouched(_:)), for: .touchUpInside)
        stackView.addTarget(self, action: #selector(stackViewTouched(_:)), for: .touchUpInside)
        
    }
    
    // MARK: - Action
    
    @objc func closeButtonTouched(_ button: UIButton) {
        PSEventHub.shared.close?()
    }
    
    @objc func doneButtonTouched(_ button: UIButton) {
        PSEventHub.shared.doneWithImages?()
    }
    
    @objc func arrowButtonTouched(_ button: PSArrowButton) {
        dropdownController.toggle()
        button.toggle(dropdownController.expanding)
    }
    
    @objc func stackViewTouched(_ stackView: PSStackView) {
        PSEventHub.shared.stackViewTouched?()
    }
    
    func show(album: PSAlbum) {
        gridView.arrow.updateText(album.collection.localizedTitle ?? "")
        items = album.items
        gridView.collectionView.reloadData()
        gridView.collectionView.scrollToTop()
        gridView.emptyView.isHidden = !items.isEmpty
    }
    
    func refreshSelectedAlbum() {
        if let album = selectedAlbum {
            album.reload()
            show(album: album)
        }
    }
    
    // MARK: - View
    
    func refreshView() {
        let hasImages = !cart.images.isEmpty
        gridView.bottomView.fade(visible: hasImages)
        gridView.collectionView.updateBottomInset(hasImages ? gridView.bottomView.frame.size.height : 0)
    }

}

extension PSPhotoController: PSDropdownControllerDelegate {
    
    func dropdownController(_ controller: PSDropdownController, didSelect album: PSAlbum) {
        selectedAlbum = album
        show(album: album)
        
        dropdownController.toggle()
        gridView.arrow.toggle(controller.expanding)
    }
}

extension PSPhotoController: PSPageAware {
    func pageDidShow() {
        once.run {
            library.reload {
                self.gridView.loadingIndicator.stopAnimating()
                self.dropdownController.albums = self.library.albums
                self.dropdownController.tableView.reloadData()
                
                if let album = self.library.albums.first {
                    self.selectedAlbum = album
                    self.show(album: album)
                }
            }
        }
    }
}

extension PSPhotoController: PSCartDelegate {
    
    func cart(_ cart: PSCart, didAdd image: PSImage, newlyTaken: Bool) {
        stackView.reload(cart.images, added: true)
        refreshView()
        if newlyTaken {
            refreshSelectedAlbum()
        }
    }
    
    func cart(_ cart: PSCart, didRemove image: PSImage) {
        stackView.reload(cart.images)
        refreshView()
    }
    
    func cartDidReload(_ cart: PSCart) {
        stackView.reload(cart.images)
        refreshView()
        refreshSelectedAlbum()
    }
}

extension PSPhotoController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PSImageCell.self), for: indexPath)
            as! PSImageCell
        let item = items[(indexPath as NSIndexPath).item]
        
        cell.configure(item)
        configureFrameView(cell, indexPath: indexPath)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = (collectionView.bounds.size.width - (PSGalleryConfig.Grid.Dimension.columnCount - 1) * PSGalleryConfig.Grid.Dimension.cellSpacing)
            / PSGalleryConfig.Grid.Dimension.columnCount
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[(indexPath as NSIndexPath).item]
        
        if cart.images.contains(item)
        {
            cart.remove(item)
            /// 如果是之前选满了图片需要刷新视图
            if PSGalleryConfig.Camera.maxCount != 0 && PSGalleryConfig.Camera.maxCount - 1 == cart.images.count
            {
                collectionView.reloadData()
            }
        }
        else
        {
            if PSGalleryConfig.Camera.maxCount == 0 || PSGalleryConfig.Camera.maxCount > cart.images.count{
                cart.add(item)
                /// Add mask view while finish select photos
                if PSGalleryConfig.Camera.maxCount != 0 && PSGalleryConfig.Camera.maxCount == cart.images.count
                {
                    collectionView.reloadData()
                }
            }
            else
            {
                var style = ToastStyle()
                style.backgroundColor = .clear
                style.messageColor = .red
                self.view.hideToast()
                self.view.makeToast("Gallery.Photo.Limit".localized(string: "Limit \(PSGalleryConfig.Camera.maxCount) pictures"), duration: ToastManager.shared.duration, point: view.center, title: "", image: nil, style: style, completion: nil)

            }
        }
        configureFrameViews()
    }
    
    func configureFrameViews() {
        for case let cell as PSImageCell in gridView.collectionView.visibleCells {
            if let indexPath = gridView.collectionView.indexPath(for: cell) {
                configureFrameView(cell, indexPath: indexPath)
            }
        }
    }
    
    func configureFrameView(_ cell: PSImageCell, indexPath: IndexPath) {
        let item = items[(indexPath as NSIndexPath).item]
        
        if let index = cart.images.index(of: item) {
            cell.masView?.isHidden = true
            cell.frameView.quickFade()
            cell.frameView.label.text = "\(index + 1)"
        } else {
            cell.frameView.alpha = 0
            if PSGalleryConfig.Camera.maxCount == cart.images.count && cart.images.count != 0
            {
                cell.masView?.isHidden = false
            }else{
                cell.masView?.isHidden = true
            }
        }
    }
}
