//
//  PSCameraView.swift
//  PSSwiftyML
//
//  Created by Aaron on 2019/1/31.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit
import AVFoundation

protocol PSCameraViewDelegate: class {
    func cameraView(_ cameraView: PSCameraView, didTouch point: CGPoint)
}

class PSCameraView: UIView {

    lazy var closeButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(PSGalleryBundle.image("gallery_close"), for: UIControl.State())
        addSubview(btn)
        return btn
    }()
    
    lazy var flashButton: PSFlashButton = {
        
        let states: [PSFlashButton.FlashState] = [
            PSFlashButton.FlashState(title:"Gallery.Camera.Flash.Off".localized(string: "OFF"),
                                      image: PSGalleryBundle.image("gallery_camera_flash_off")!),
            PSFlashButton.FlashState(title: "Gallery.Camera.Flash.On".localized(string: "ON"),
                                      image: PSGalleryBundle.image("gallery_camera_flash_on")!),
            PSFlashButton.FlashState(title: "Gallery.Camera.Flash.Auto".localized(string: "AUTO"),
                                     image: PSGalleryBundle.image("gallery_camera_flash_auto")!)
        ]
        
        let btn = PSFlashButton(states: states)
        addSubview(btn)
        return btn
    }()
    
    lazy var rotateButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(PSGalleryBundle.image("gallery_camera_rotate"), for: UIControl.State())
        addSubview(btn)
        return btn
    }()
    
    lazy var bottomContainer: UIView = {
        let v = UIView()
        addSubview(v)
        return v
    }()
    
    lazy var bottomView: UIView = {
        let v = UIView()
        v.backgroundColor = PSGalleryConfig.Camera.BottomContainer.backgroundColor
        v.alpha = 0
        bottomContainer.addSubview(v)
        return v
    }()
    
    lazy var shutterButton: PSShutterButton = {
        let btn = PSShutterButton()
        btn.addShadow()
        bottomContainer.addSubview(btn)
        return btn
    }()
    
    lazy var stackView: PSStackView = {
        let sv = PSStackView()
        bottomView.addSubview(sv)
        return sv
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
    
    lazy var focusImageView: UIImageView = {
        let iv = UIImageView()
        iv.frame.size = CGSize(width: 110, height: 110)
        iv.image = PSGalleryBundle.image("gallery_camera_focus")
        iv.backgroundColor = .clear
        iv.alpha = 0
        
        return iv
    }()

    lazy var tapGR: UITapGestureRecognizer = {
        let gr = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
        gr.delegate = self
        
        return gr
    }()
    
    lazy var rotateOverlayView: UIView = {
        let v = UIView()
        v.alpha = 0
        
        return v
    }()
    
    lazy var shutterOverlayView: UIView = {
        let v = UIView()
        v.alpha = 0
        v.backgroundColor = UIColor.black
        
        return v
    }()
    
    lazy var blurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .dark)
        let ev = UIVisualEffectView(effect: effect)
        
        return ev
    }()
    var timer: Timer?
    var previewLayer: AVCaptureVideoPreviewLayer?
    weak var delegate: PSCameraViewDelegate?
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.black
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        previewLayer?.frame = self.layer.bounds
    }
    
    // MARK: - Setup
    private func setup() {
        addGestureRecognizer(tapGR)
        
        [closeButton, flashButton, rotateButton].forEach {
            $0.addShadow()
        }
        
        rotateOverlayView.addSubview(blurView)
        insertSubview(rotateOverlayView, belowSubview: rotateButton)
        insertSubview(focusImageView, belowSubview: bottomContainer)
        insertSubview(shutterOverlayView, belowSubview: bottomContainer)
        
        closeButton.ps_makeConstraint(attribute: .left)
        closeButton.ps_makeSize(CGSize(width: 44, height: 44))
        
        flashButton.ps_makeConstraint(attribute: .centerY, toView: closeButton)
        flashButton.ps_makeConstraint(attribute: .centerX)
        flashButton.ps_makeSize(CGSize(width: 60, height: 44))
        
        rotateButton.ps_makeConstraint(attribute: .right)
        rotateButton.ps_makeSize(CGSize(width: 44, height: 44))

        if #available(iOS 11, *) {
            Constraint.on(
                closeButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                rotateButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor)
            )
        } else {
            Constraint.on(
                closeButton.topAnchor.constraint(equalTo: topAnchor),
                rotateButton.topAnchor.constraint(equalTo: topAnchor)
            )
        }
        
        bottomContainer.ps_makeDownward()
        bottomContainer.ps_makeHeight(80)
        bottomView.ps_makeEdges()
        
        stackView.ps_makeConstraint(attribute: .centerY, constant: -4)
        stackView.ps_makeConstraint(attribute: .left, constant: 38)
        stackView.ps_makeSize(CGSize(width: 60, height: 60))
        
        shutterButton.ps_makeCenter()
        shutterButton.ps_makeSize(CGSize(width: 60, height: 60))
        
        doneButton.ps_makeConstraint(attribute: .centerY)
        doneButton.ps_makeConstraint(attribute: .right, constant: -38)
        
        rotateOverlayView.ps_makeEdges()
        blurView.ps_makeEdges()
        shutterOverlayView.ps_makeEdges()
        
    }
    
    func setupPreviewLayer(_ session: AVCaptureSession) {
        guard previewLayer == nil else { return }
        
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.autoreverses = true
        layer.videoGravity = .resizeAspectFill
        layer.connection?.videoOrientation = PSUtils.videoOrientation()
        
        self.layer.insertSublayer(layer, at: 0)
        layer.frame = self.layer.bounds
        
        previewLayer = layer
    }
    
    // MARK: - Action
    
    @objc func viewTapped(_ gr: UITapGestureRecognizer) {
        let point = gr.location(in: self)
        
        focusImageView.transform = CGAffineTransform.identity
        timer?.invalidate()
        delegate?.cameraView(self, didTouch: point)
        
        focusImageView.center = point
        
        UIView.animate(withDuration: 0.5, animations: {
            self.focusImageView.alpha = 1
            self.focusImageView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        }, completion: { _ in
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self,
                                              selector: #selector(PSCameraView.timerFired(_:)), userInfo: nil, repeats: false)
        })
    }
    
    @objc func timerFired(_ timer: Timer) {
        UIView.animate(withDuration: 0.3, animations: {
            self.focusImageView.alpha = 0
        }, completion: { _ in
            self.focusImageView.transform = CGAffineTransform.identity
        })
    }
}

extension PSCameraView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let point = gestureRecognizer.location(in: self)
        
        return point.y > closeButton.frame.maxY
            && point.y < bottomContainer.frame.origin.y
    }
}
