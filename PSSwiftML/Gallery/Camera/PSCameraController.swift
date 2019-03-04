//
//  PSCameraController.swift
//  PSSwiftyML
//
//  Created by Aaron on 2019/1/31.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit
import AVFoundation

class PSCameraController: UIViewController {

    // MARK: - Properties
    var locationManager: PSLocationManager?
    let once = PSOnce()
    let cart: PSCart
    
    lazy var cameraManager: PSCameraManager = {
        let camera = PSCameraManager()
        camera.delegate = self
        return camera
    }()
    
    lazy var cameraView: PSCameraView = {
        let cv = PSCameraView()
        cv.delegate = self
        
        return cv
    }()
    
    // MAKR: - Lifecycle
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
        setupLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        locationManager?.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        locationManager?.stop()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { _ in
            if let connection = self.cameraView.previewLayer?.connection,
                connection.isVideoOrientationSupported {
                connection.videoOrientation = PSUtils.videoOrientation()
            }
        }, completion: nil)
        
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    // MARK: - Setup
    
    func setup() {
        view.addSubview(cameraView)
        view.backgroundColor = .white
        cameraView.ps_makeEdges()
        cameraView.closeButton.addTarget(self, action: #selector(closeButtonTouched(_:)), for: .touchUpInside)
        cameraView.flashButton.addTarget(self, action: #selector(flashButtonTouched(_:)), for: .touchUpInside)
        cameraView.rotateButton.addTarget(self, action: #selector(rotateButtonTouched(_:)), for: .touchUpInside)
        cameraView.stackView.addTarget(self, action: #selector(stackViewTouched(_:)), for: .touchUpInside)
        cameraView.shutterButton.addTarget(self, action: #selector(shutterButtonTouched(_:)), for: .touchUpInside)
        cameraView.doneButton.addTarget(self, action: #selector(doneButtonTouched(_:)), for: .touchUpInside)
    }
    
    func setupLocation() {
        if PSGalleryConfig.Camera.recordLocation {
            locationManager = PSLocationManager()
        }
    }
    // MARK: - Action
    
    @objc func closeButtonTouched(_ button: UIButton) {
        PSEventHub.shared.close?()
    }
    
    @objc func flashButtonTouched(_ button: UIButton) {
        cameraView.flashButton.toggle()
        
        if let flashMode = AVCaptureDevice.FlashMode(rawValue: cameraView.flashButton.selectedIndex) {
            cameraManager.switchFlashMode(flashMode)
        }
    }
    
    @objc func rotateButtonTouched(_ button: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
            self.cameraView.rotateOverlayView.alpha = 1
        }, completion: { _ in
            self.cameraManager.switchCamera {
                UIView.animate(withDuration: 0.7, animations: {
                    self.cameraView.rotateOverlayView.alpha = 0
                })
            }
        })
    }
    
    @objc func stackViewTouched(_ stackView: PSStackView) {
        PSEventHub.shared.stackViewTouched?()
    }
    
    @objc func shutterButtonTouched(_ button: PSShutterButton) {
        guard isBelowImageLimit() else { return }
        guard let previewLayer = cameraView.previewLayer else { return }
        
        button.isEnabled = false
        UIView.animate(withDuration: 0.1, animations: {
            self.cameraView.shutterOverlayView.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.cameraView.shutterOverlayView.alpha = 0
            })
        })
        
        self.cameraView.stackView.startLoading()
        cameraManager.takePhoto(previewLayer, location: locationManager?.latestLocation) { [weak self] asset in
            guard let strongSelf = self else {
                return
            }
            
            button.isEnabled = true
            strongSelf.cameraView.stackView.stopLoading()
            
            if let asset = asset {
                strongSelf.cart.add(PSImage(asset: asset), newlyToken: true)
            }
        }
    }
    
    @objc func doneButtonTouched(_ button: UIButton) {
        PSEventHub.shared.doneWithImages?()
    }
    
    fileprivate func isBelowImageLimit() -> Bool {
        return (PSGalleryConfig.Camera.maxCount == 0 || PSGalleryConfig.Camera.maxCount > cart.images.count)
    }

    // MARK: - View
    
    func refreshView() {
        let hasImages = !cart.images.isEmpty
        cameraView.bottomView.fade(visible: hasImages)
    }
}

extension PSCameraController: PSCameraViewDelegate {
    
    func cameraView(_ cameraView: PSCameraView, didTouch point: CGPoint) {
        cameraManager.focus(point)
    }
}

extension PSCameraController: PSCameraManagerDelegate {
    
    
    func cameraDidStart(_ camera: PSCameraManager) {
        cameraView.setupPreviewLayer(camera.session)
    }
    
    func cameraNotAvailable(_ camera: PSCameraManager) {
        cameraView.focusImageView.isHidden = true
    }
    
    func camera(_ camera: PSCameraManager, didChangeInput input: AVCaptureDeviceInput) {
        cameraView.flashButton.isHidden = !input.device.hasFlash
    }
    
}

extension PSCameraController: PSPageAware {
    
    func pageDidShow() {
        once.run {
            cameraManager.setup()
        }
    }
}

extension PSCameraController: PSCartDelegate {
    
    func cart(_ cart: PSCart, didAdd image: PSImage, newlyTaken: Bool) {
        cameraView.stackView.reload(cart.images, added: true)
        refreshView()
    }
    
    func cart(_ cart: PSCart, didRemove image: PSImage) {
        cameraView.stackView.reload(cart.images)
        refreshView()
    }
    
    func cartDidReload(_ cart: PSCart) {
        cameraView.stackView.reload(cart.images)
        refreshView()
    }
}

