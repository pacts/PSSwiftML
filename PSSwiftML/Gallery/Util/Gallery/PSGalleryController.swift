//
//  PSGalleryController.swift
//  PSSwiftyML
//
//  Created by Aaron on 2019/1/29.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit
import AVFoundation

public protocol PSGalleryDelegate: class {
    
    func galleryController(_ controller: PSGalleryController, didSelectImages images: [PSImage])
    func galleryController(_ controller: PSGalleryController, didSelectVideo video: PSVideo)
    func galleryController(_ controller: PSGalleryController, requestLightbox images: [PSImage])
    func galleryControllerDidCancel(_ controller: PSGalleryController)
    
}
public class PSGalleryController: UIViewController, PSPermissionControllerDelegate {

    public weak var delegate: PSGalleryDelegate?
    
    public let cart = PSCart()
    
    private lazy var photoLibrary: PSPhotoController = {
        let controller = PSPhotoController(cart: cart)
        controller.title = "Gallery.Images.Title".localized(string: "PHOTOS")
        return controller
    }()
    
    private lazy var cameraController: PSCameraController = {
        let controller = PSCameraController(cart: cart)
        controller.title = "Gallery.Camera.Title".localized(string: "CAMERA")
        return controller
    }()
    
    private lazy var videoController: PSVideoController = {
        let controller = PSVideoController(cart: cart)
        controller.title = "Gallery.Videos.Title".localized(string: "VIDEOS")
        
        return controller
    }()
    
    private func pages() -> PSPageController? {
        guard PSGalleryPermission.PhotoLibrary.status == .authorized else {
            return nil
        }
        
        let useCamera = PSGalleryPermission.Camera.needsPermission && PSGalleryPermission.Camera.status == .authorized
        
        let tabsToShow = PSGalleryConfig.items.compactMap { $0 != .camera ? $0 : (useCamera ? $0 : nil) }
        
        let controllers: [UIViewController] = tabsToShow.compactMap { tab in
            if tab == .image {
                return photoLibrary
            } else if tab == .camera {
                return cameraController
            } else if tab == .video {
                return videoController
            } else {
                return nil
            }
        }
        
        guard !controllers.isEmpty else {
            return nil
        }
        
        let controller = PSPageController(controllers: controllers)
        controller.selectedIndex = tabsToShow.firstIndex(of: PSGalleryConfig.initialTab ?? .camera) ?? 0
        
        return controller
    }
    
    private lazy var permission: PSGalleryPermissionController = {
        let controller = PSGalleryPermissionController()
        controller.delegate = self
        
        return controller
    }()
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        if let pagesController = pages() {
            ps_addChildController(pagesController)
        } else {
            ps_addChildController(permission)
        }
    }

    func setup() {
        PSEventHub.shared.close = { [weak self] in
            if let strongSelf = self {
                strongSelf.delegate?.galleryControllerDidCancel(strongSelf)
            }
        }
        
        PSEventHub.shared.doneWithImages = { [weak self] in
            if let strongSelf = self {
                strongSelf.delegate?.galleryController(strongSelf, didSelectImages: strongSelf.cart.images)
            }
        }
        
        PSEventHub.shared.doneWithVideos = { [weak self] in
            if let strongSelf = self, let video = strongSelf.cart.video {
                strongSelf.delegate?.galleryController(strongSelf, didSelectVideo: video)
            }
        }
        
        PSEventHub.shared.stackViewTouched = { [weak self] in
            if let strongSelf = self {
                strongSelf.delegate?.galleryController(strongSelf, requestLightbox: strongSelf.cart.images)
            }
        }
    }
    
    // MARK: - PermissionControllerDelegate
    
    func permissionControllerDidFinish(_ controller: PSGalleryPermissionController) {
        if let pagesController = pages() {
            ps_addChildController(pagesController)
            controller.ps_removeFromParentController()
        }
    }
}

