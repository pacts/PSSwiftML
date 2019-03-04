//
//  PSVideoController.swift
//  PSSwiftyML
//
//  Created by Aaron on 2019/2/3.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit
import AVKit
import Photos

class PSVideoController: UIViewController {

    lazy var gridView: PSGridView = {
        let gv = PSGridView()
        gv.bottomView.alpha = 0
        view.addSubview(gv)
        return gv
    }()
    
    lazy var videoBox: PSVideoBox = {
        let box = PSVideoBox()
        box.delegate = self
        gridView.bottomView.addSubview(box)
        return box
    }()
    
    lazy var infoLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = UIColor.white
        lb.font = PSGalleryConfig.Font.Text.regular.withSize(12)
        lb.text = String(format: "Gallery.Videos.MaxiumDuration".localized(string: "FIRST %d SECONDS"),
                            (Int(PSGalleryConfig.VideoEditor.maximumDuration)))
        gridView.bottomView.addSubview(lb)
        return lb
    }()
    let cart: PSCart
    let once = PSOnce()
    let library = PSVideoLibrary()
    var items: [PSVideo] = []
    
    public required init(cart: PSCart) {
        self.cart = cart
        super.init(nibName: nil, bundle: nil)
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
        view.backgroundColor = .white
        
        gridView.ps_makeEdges()
        
        videoBox.ps_makeSize(CGSize(width: 44, height: 44))
        videoBox.ps_makeConstraint(attribute: .centerY)
        videoBox.ps_makeConstraint(attribute: .left, constant: 38)
        
        infoLabel.ps_makeConstraint(attribute: .centerY)
        infoLabel.ps_makeConstraint(attribute: .left, toView: videoBox, on: .right, constant: 11)
        infoLabel.ps_makeConstraint(attribute: .right, constant: -50)
        
        gridView.collectionView.dataSource = self
        gridView.collectionView.delegate = self
        gridView.collectionView.register(PSVideoCell.self,
                                         forCellWithReuseIdentifier: String(describing: PSVideoCell.self))
        
        gridView.arrow.updateText("Gallery.AllVideos".localized(string: "ALL VIDEOS"))
        gridView.arrow.arrow.isHidden = true
        
        gridView.closeButton.addTarget(self, action: #selector(closeButtonTouched(_:)), for: .touchUpInside)
        gridView.doneButton.addTarget(self, action: #selector(doneButtonTouched(_:)), for: .touchUpInside)
    }
    // MARK: - View
    
    func refreshView() {
        if let selectedItem = cart.video {
            videoBox.imageView.loadImage(selectedItem.asset)
        } else {
            videoBox.imageView.image = nil
        }
        
        let hasVideo = (cart.video != nil)
        gridView.bottomView.fade(visible: hasVideo)
        gridView.collectionView.updateBottomInset(hasVideo ? gridView.bottomView.h : 0)
        
        cart.video?.fetchDuration { [weak self] duration in
            self?.infoLabel.isHidden = duration <= PSGalleryConfig.VideoEditor.maximumDuration
        }
    }
    
    @objc func closeButtonTouched(_ button: UIButton) {
        PSEventHub.shared.close?()
    }
    
    @objc func doneButtonTouched(_ button: UIButton) {
        PSEventHub.shared.doneWithVideos?()
    }
}

extension PSVideoController: PSPageAware {
    
    func pageDidShow() {
        once.run {
            library.reload {
                self.gridView.loadingIndicator.stopAnimating()
                self.items = self.library.items
                self.gridView.collectionView.reloadData()
                self.gridView.emptyView.isHidden = !self.items.isEmpty
            }
        }
    }
}

extension PSVideoController: PSVideoBoxDelegate {
    
    func videoBoxDidTap(_ videoBox: PSVideoBox) {
        cart.video?.fetchPlayerItem { item in
            guard let item = item else { return }
            
            DispatchQueue.main.async {
                let controller = AVPlayerViewController()
                let player = AVPlayer(playerItem: item)
                controller.player = player
                self.present(controller, animated: true) {
                    player.play()
                }
            }
        }
    }
}

extension PSVideoController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PSVideoCell.self), for: indexPath)
            as! PSVideoCell
        let item = items[(indexPath as NSIndexPath).item]
        
        cell.configure(item)
        cell.frameView.label.isHidden = true
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
        
        if let selectedItem = cart.video , selectedItem == item {
            cart.video = nil
        } else {
            cart.video = item
        }
        
        refreshView()
        configureFrameViews()
    }
    
    func configureFrameViews() {
        for case let cell as PSVideoCell in gridView.collectionView.visibleCells {
            if let indexPath = gridView.collectionView.indexPath(for: cell) {
                configureFrameView(cell, indexPath: indexPath)
            }
        }
    }
    
    func configureFrameView(_ cell: PSVideoCell, indexPath: IndexPath) {
        let item = items[(indexPath as NSIndexPath).item]
        
        if let selectedItem = cart.video , selectedItem == item {
            cell.frameView.quickFade()
        } else {
            cell.frameView.alpha = 0
        }
    }
}
