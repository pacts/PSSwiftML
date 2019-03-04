//
//  PSClipController.swift
//  PSSwiftyML
//
//  Created by Aaron on 2019/2/12.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit

class PSClipController: UIViewController {
    
    
    let clipRectWidth = UIScreen.main.bounds.size.width
    let TimesThanMin: CGFloat = 5.0
    
    let kScreenWidth = UIApplication.shared.keyWindow!.w
    let kScreenHeight = UIApplication.shared.keyWindow!.h
    var finishBlock: ((UIImage) ->Void)?
    var image: UIImage!
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        commonInit()
        settingScrollViewZoomScale()
    }
    
    deinit {
    }
    
    // MARK: - Action
    @objc func commonAction(_ button: UIButton) {
        guard button.tag == 8086 else {
            navigationController?.popViewController(animated: true)
            return
        }
        let image = clipImage()
        finishBlock!(image!)
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Private
    private func commonInit() {
        
        let clipRectX = (kScreenWidth - clipRectWidth) / 2.0
        let clipRectY = (kScreenHeight - clipRectWidth) / 2.0
        
        /// add scroll view
        scrollView = UIScrollView.init(frame: view.bounds)
        scrollView.delegate = self
        scrollView.backgroundColor = UIColor.lightGray
        scrollView.contentInset = UIEdgeInsets.init(top: clipRectY,
                                                    left: clipRectX,
                                                    bottom: clipRectY,
                                                    right: clipRectX)
        
        let imageViewH = image.size.height / image.size.width * kScreenWidth
        imageView = UIImageView.init(frame: CGRect.init(x: 0,
                                                        y: 0,
                                                        width: kScreenWidth,
                                                        height: imageViewH))
        imageView.image = image
        scrollView.addSubview(imageView)
        
        let offsetY = (scrollView.bounds.height - imageViewH) / 2.0
        scrollView.setContentOffset(CGPoint.init(x: 0,
                                                 y: -offsetY),
                                    animated: false)
        
        view.addSubview(scrollView)
        
        /// add clip rect
        let maskView = UIView.init(frame: view.bounds)
        maskView.backgroundColor = UIColor.clear
        maskView.isUserInteractionEnabled = false
        
        
        
        let path = UIBezierPath.init(rect: view.bounds)
        let rectPath = UIBezierPath(rect: CGRect(x: clipRectX,
                                                 y: clipRectY,
                                                 width: clipRectWidth,
                                                 height: clipRectWidth))
        path.append(rectPath)
        
        let shaperLayer = CAShapeLayer.init()
        shaperLayer.fillRule = CAShapeLayerFillRule.evenOdd
        shaperLayer.path = path.cgPath
        shaperLayer.fillColor = UIColor.white.withAlphaComponent(0.8).cgColor
        
        let whiteRectLayer = CAShapeLayer.init()
        whiteRectLayer.lineWidth = 2;
        whiteRectLayer.path = rectPath.cgPath
        whiteRectLayer.fillColor = UIColor.clear.cgColor
        whiteRectLayer.strokeColor = UIColor.green.cgColor
        shaperLayer.addSublayer(whiteRectLayer)
        maskView.layer.addSublayer(shaperLayer)
        view.addSubview(maskView)
        
        /// add bottom view
        let bottomView = UIView.init(frame: CGRect.init(x: 0,
                                                        y: kScreenHeight - 60 - SafeAreaBottom(),
                                                        width: kScreenWidth,
                                                        height: 60 + SafeAreaBottom()))
        bottomView.backgroundColor = UIColor.white
        
        let confirmButton = UIButton.init(frame: CGRect.init(x: kScreenWidth*3/4 - 20,
                                                             y: 10,
                                                             width: 40,
                                                             height: 40))
        confirmButton.tintColor = .green
        confirmButton.setImage(UIImage(named: "app_check")?.withRenderingMode(.alwaysTemplate), for: .normal)
        confirmButton.addTarget(self,
                                action: #selector(PSClipController.commonAction(_:)),
                                for: UIControl.Event.touchUpInside)
        confirmButton.tag = 8086
        bottomView.addSubview(confirmButton)
        
        let cancelButton = UIButton.init(frame: CGRect.init(x: kScreenWidth/4 - 20,
                                                            y: 10,
                                                            width: 40,
                                                            height: 40))
        cancelButton.tintColor = .red
        cancelButton.setImage(UIImage(named: "app_cancel")?.withRenderingMode(.alwaysTemplate), for: .normal)
        cancelButton.addTarget(self,
                               action: #selector(PSClipController.commonAction(_:)),
                               for: UIControl.Event.touchUpInside)
        bottomView.addSubview(cancelButton)
        
        view.addSubview(bottomView)
    }
    
    private func settingScrollViewZoomScale() {
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        
        if imageWidth > imageHeight {
            scrollView.minimumZoomScale = clipRectWidth / (imageHeight / imageWidth * kScreenWidth);
        } else {
            scrollView.minimumZoomScale = clipRectWidth / kScreenWidth;
        }
        scrollView.maximumZoomScale = (scrollView.minimumZoomScale) * TimesThanMin
        scrollView.zoomScale = scrollView.minimumZoomScale > 1 ? scrollView.minimumZoomScale : 1
    }
    
    private func clipImage() -> UIImage? {
        let offset = scrollView.contentOffset
        let imageSize = imageView.image?.size
        let scale = (imageView.frame.size.width) / (imageSize?.width)! / image.scale
        
        let clipRectX = (kScreenWidth - clipRectWidth) / 2.0
        let clipRectY = (kScreenHeight - clipRectWidth) / 2.0
        
        let rectX = (offset.x + clipRectX) / scale
        let rectY = (offset.y + clipRectY) / scale
        let rectWidth = clipRectWidth / scale
        let rectHeight = rectWidth
        
        let rect = CGRect.init(x: rectX,
                               y: rectY,
                               width: rectWidth,
                               height: rectHeight)
        let fixedImage = fixedImageOrientation(image)
        let resultImage = fixedImage?.cgImage?.cropping(to: rect)
        let clipImage = UIImage.init(cgImage: resultImage!)
        
        return clipImage
    }
    
    private func fixedImageOrientation(_ image: UIImage) -> UIImage? {
        if image.imageOrientation == .up {
            return image
        }
        
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        let π = Double.pi
        var transform = CGAffineTransform.identity
        
        switch image.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: imageWidth,
                                               y: imageHeight)
            transform = transform.rotated(by: CGFloat(π))
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: imageWidth,
                                               y: 0)
            transform = transform.rotated(by: CGFloat(π / 2))
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0,
                                               y: imageHeight)
            transform = transform.rotated(by: CGFloat(-π / 2))
        default:
            break
        }
        
        switch image.imageOrientation {
        case .up, .upMirrored:
            transform = transform.translatedBy(x: imageWidth,
                                               y: 0)
            transform = transform.scaledBy(x: -1,
                                           y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: imageHeight,
                                               y: 0)
            transform = transform.scaledBy(x: -1,
                                           y: 1)
        default:
            break
        }
        
        let context = CGContext.init(data: nil,
                                     width: Int(imageWidth),
                                     height: Int(imageHeight),
                                     bitsPerComponent: Int(image.cgImage!.bitsPerComponent),
                                     bytesPerRow: Int((image.cgImage?.bytesPerRow)!),
                                     space: CGColorSpaceCreateDeviceRGB(),
                                     bitmapInfo: (image.cgImage?.bitmapInfo.rawValue)!)
        context!.concatenate(transform)
        
        switch image.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context?.draw(image.cgImage!, in: CGRect.init(x: 0,
                                                          y: 0,
                                                          width: imageHeight,
                                                          height: imageWidth))
        default:
            context?.draw(image.cgImage!, in: CGRect.init(x: 0,
                                                          y: 0,
                                                          width: imageWidth,
                                                          height: imageHeight))
        }
        
        let fixedImage = UIImage.init(cgImage: context!.makeImage()!)
        return fixedImage
    }
    
}

extension PSClipController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
