//
//  PSScannerController.swift
//  PSSwiftyML
//
//  Created by Aaron on 2019/2/12.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import Vision


@available(iOS 11.0, *)
class PSScannerController: UIViewController {

    private lazy var closeButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "app_cancel"), for: .normal)
        view.addSubview(btn)
        return btn
    }()
    
    private lazy var categoryLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .red
        lb.textAlignment = .center
        view.addSubview(lb)
        return lb
    }()
    
    let once = PSOnce()

    private let sessionQueue = DispatchQueue(label: "Gallery.Camera.SessionQueue",
                                             qos: .background)
    private let visionSequenceHandler = VNSequenceRequestHandler()

    let session = AVCaptureSession()
    
    var backCamera: AVCaptureDeviceInput?
    var videoOutput: AVCaptureVideoDataOutput?
    
    private var cameraManager: PSCameraManager?
    
    private var previewLayer: AVCaptureVideoPreviewLayer?

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        once.run {
            setupCamera()
        }
    }
    
    deinit {
        session.stopRunning()
    }
    
    private func setup() {
        closeButton.x = 5
        closeButton.y = SafeAreaTop()
        closeButton.w = 44
        closeButton.h = 44
        
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        
        categoryLabel.x = 0
        categoryLabel.y = UIScreen.main.bounds.height - SafeAreaBottom() - 40
        categoryLabel.w = UIScreen.main.bounds.width
        categoryLabel.h = 40
    }
    
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
    func setupPreviewLayer(_ session: AVCaptureSession) {
        guard previewLayer == nil else { return }
        
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.autoreverses = true
        layer.videoGravity = .resizeAspectFill
        layer.connection?.videoOrientation = PSUtils.videoOrientation()
        
        view.layer.insertSublayer(layer, at: 0)
        layer.frame = view.layer.bounds
        
        previewLayer = layer
    }
    
   
    private func setupCamera() {
        self.backCamera = try? AVCaptureDeviceInput(device: AVCaptureDevice.default(.builtInWideAngleCamera,
                                                                                    for: AVMediaType.video, position: .back)!)
        videoOutput = AVCaptureVideoDataOutput()
        videoOutput!.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA),
            kCVPixelBufferWidthKey as String: NSNumber(value: 224),
            kCVPixelBufferHeightKey as String: NSNumber(value: 224)
        ]
        videoOutput?.setSampleBufferDelegate(self, queue: sessionQueue)
        
        if session.canAddInput(backCamera!) {
            session.addInput(backCamera!)
        }
        
        if session.canAddOutput(videoOutput!) {
            session.addOutput(videoOutput!)
            
        }
        
        sessionQueue.async {
            self.session.startRunning()
            DispatchQueue.main.async {
                self.setupPreviewLayer(self.session)
            }
        }
    }
}

// MARK: AVCaptureVideoDataOutputSampleBufferDelegate
@available(iOS 11.0, *)
extension PSScannerController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
                let resnet = Resnet50()
                let model = try? VNCoreMLModel(for: resnet.model)

                let request = VNCoreMLRequest(model: model!, completionHandler: handleVisionRequestUpdate)
//                try? print(resnet.prediction(image: imageBuffer).classLabel)
                do {
                        try visionSequenceHandler.perform(
                            [request],
                            on: imageBuffer,
                            orientation: CGImagePropertyOrientation(rawValue: 0) ?? .left
                        )
                } catch {
                    print("Throws: \(error)")
                }
        }
    }
    
    private func handleVisionRequestUpdate(_ request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let topResult = request.results?.first as? VNClassificationObservation else {
                return
            }
            self.categoryLabel.text = topResult.identifier
        }
    }
}
