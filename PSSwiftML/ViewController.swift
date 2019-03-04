//
//  ViewController.swift
//  PSSwiftML
//
//  Created by Aaron on 2019/2/20.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    private lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        view.addSubview(iv)
        return iv
    }()
    
    private lazy var categoryLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .red
        lb.textAlignment = .center
        view.addSubview(lb)
        return lb
    }()
    
    private lazy var pickButton: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(pickImage), for: .touchUpInside)
        btn.setTitle("Pick Image", for: .normal)
        btn.setTitleColor(.blue, for: .normal)
        view.addSubview(btn)
        return btn
    }()
    
    @available(iOS 11.0, *)
    private lazy var scannerButton: UIButton = {
        let btn = UIButton()
        
        btn.addTarget(self, action: #selector(scan), for: .touchUpInside)
        btn.setTitle("Scanner", for: .normal)
        btn.setTitleColor(.blue, for: .normal)
        view.addSubview(btn)
        return btn
    }()
    
    private var gallery: PSGalleryController?
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    private func setup() {
        self.view.backgroundColor = UIColor(hex: 0xFFFFFF)
        
        imageView.y = SafeAreaTop() + 20
        imageView.w = 224
        imageView.h = 224
        imageView.centerX = view.centerX
        
        categoryLabel.x = 0
        categoryLabel.y = SafeAreaTop() + 224 + 20
        categoryLabel.w = view.w
        categoryLabel.h = 30
        
        pickButton.y = categoryLabel.bottom + 20
        pickButton.w = 100
        pickButton.h = 40
        pickButton.centerX = view.centerX
        
        if #available(iOS 11.0, *) {
            scannerButton.y = pickButton.bottom + 20
            scannerButton.w = 100
            scannerButton.h = 40
            scannerButton.centerX = view.centerX
        } else {
            // Fallback on earlier versions
        }
    }
    
    @objc func pickImage() {
        PSGalleryConfig.items = [.image, .camera]
        PSGalleryConfig.Camera.maxCount = 1
        gallery = PSGalleryController()
        gallery?.title = "相册"
        gallery?.delegate = self
        let iNav = UINavigationController(rootViewController: gallery!)
        gallery?.navigationController?.isNavigationBarHidden = true
        present(iNav, animated: true, completion: nil)
    }
    
    @available(iOS 11.0, *)
    @objc func scan() {
        let scanner = PSScannerController()
        present(scanner, animated: true, completion: nil)
    }
    
    private func pixelBufferFromCGImage(image: CGImage) -> CVPixelBuffer? {
        let options = [kCVPixelBufferCGImageCompatibilityKey: true,
                       kCVPixelBufferCGBitmapContextCompatibilityKey: true]
        
        var pxbuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, image.width, image.height, kCVPixelFormatType_32ARGB, options as CFDictionary, &pxbuffer)
        guard status == kCVReturnSuccess else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pxbuffer!, [])
        let pxdata = CVPixelBufferGetBaseAddress(pxbuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        
        let context = CGContext(data: pxdata, width: image.width,
                                height: image.height, bitsPerComponent: 8, bytesPerRow: 4*image.width, space: rgbColorSpace, bitmapInfo: image.bitmapInfo.rawValue)
        context!.concatenate(CGAffineTransform(rotationAngle: 0))
        let flipVertical = CGAffineTransform( a: 1, b: 0, c: 0, d: -1, tx: 0, ty: CGFloat(image.height) )
        context!.concatenate(flipVertical)
        let flipHorizontal = CGAffineTransform( a: -1.0, b: 0.0, c: 0.0, d: 1.0, tx: CGFloat(image.width), ty: 0.0 )
        context!.concatenate(flipHorizontal)
        
        context?.draw(image, in: CGRect(x: 0, y: 0, width: image.width,
                                        height: image.height))
        
        CVPixelBufferUnlockBaseAddress(pxbuffer!, []);
        
        return pxbuffer
    }
    
    private func scale(image: UIImage, toSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(toSize)
        image.draw(in: CGRect(x: 0, y: 0, width: toSize.width, height: toSize.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
    
    
}

extension ViewController: PSGalleryDelegate {
    
    func galleryController(_ controller: PSGalleryController, didSelectImages images: [PSImage]) {
        
        PSImage.resolve(images: images, completion: {[weak self] (images) in
            if let strongSelf = self {
                if #available(iOS 11.0, *) {
                    
                    let clip = PSClipController()
                    clip.image = images[0]
                    clip.finishBlock = { (image) in
                        let scaledImage = strongSelf.scale(image: image, toSize: CGSize(width: 224, height: 224))
                        let resnet = Resnet50()
                        try! strongSelf.categoryLabel.text = resnet.prediction(image: strongSelf.pixelBufferFromCGImage(image: (scaledImage!.cgImage)!)!).classLabel
                        strongSelf.imageView.image = scaledImage
                        strongSelf.gallery?.dismiss(animated: true, completion: nil)
                        
                        strongSelf.gallery = nil
                    }
                    strongSelf.gallery?.navigationController!.pushViewController(clip, animated: true)
                    
                    
                } else {
                    // Fallback on earlier versions
                    strongSelf.imageView.image = images[0]
                    
                }
            }
            
        })
    }
    
    func galleryController(_ controller: PSGalleryController, didSelectVideo video: PSVideo) {
        gallery?.dismiss(animated: true, completion: nil)
        gallery = nil
    }
    
    func galleryController(_ controller: PSGalleryController, requestLightbox images: [PSImage]) {
        gallery?.dismiss(animated: true, completion: nil)
        gallery = nil
    }
    
    func galleryControllerDidCancel(_ controller: PSGalleryController) {
        gallery?.dismiss(animated: true, completion: nil)
        gallery = nil
    }
    
    
}
