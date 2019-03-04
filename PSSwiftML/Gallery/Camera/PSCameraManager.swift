//
//  PSCameraManager.swift
//  PSSwiftyML
//
//  Created by Aaron on 2019/1/30.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit
import AVFoundation
import PhotosUI
import Photos

protocol PSCameraManagerDelegate: class {
    func cameraNotAvailable(_ camera: PSCameraManager)
    func cameraDidStart(_ camera: PSCameraManager)
    func camera(_ cameran: PSCameraManager, didChangeInput input: AVCaptureDeviceInput)
}
class PSCameraManager: NSObject {
    
    weak var delegate: PSCameraManagerDelegate?
    
    let session = AVCaptureSession()
    
    let sessionQueue = DispatchQueue(label: "no.hyper.Gallery.Camera.SessionQueue",
                                     qos: .background)
    let savingQueue = DispatchQueue(label: "no.hyper.Gallery.Camera.SavingQueue",
                                    qos: .background)

    var backCamera: AVCaptureDeviceInput?
    var frontCamera: AVCaptureDeviceInput?
    var photoOutput: AVCapturePhotoOutput?
    
    var flashMode: AVCaptureDevice.FlashMode = .off
    var location: CLLocation?
    var completion: ((PHAsset?) -> Void)?
    
    let preferredPresets: [AVCaptureSession.Preset] = [.high, .medium, .low]
    
    var currentInput: AVCaptureDeviceInput? {
        return session.inputs.first as? AVCaptureDeviceInput
    }
    deinit {
        stop()
    }
    
    func setup() {
        if PSGalleryPermission.Camera.status == .authorized {
            self.start()
        } else {
            self.delegate?.cameraNotAvailable(self)
        }
    }
    
    func setupDevices() {
        // Input
        let devices = [AVCaptureDevice.default(.builtInWideAngleCamera,
                                               for: AVMediaType.video, position: .back),
                       AVCaptureDevice.default(.builtInWideAngleCamera,
                                               for: AVMediaType.video, position: .front)]
        devices.forEach { (device) in
            switch device?.position {
            case .front?:
                self.frontCamera = try? AVCaptureDeviceInput(device: device!)
            case .back?:
                self.backCamera = try? AVCaptureDeviceInput(device: device!)
            default:
                break
            }
        }
        // Output
        photoOutput = AVCapturePhotoOutput()
    }
    
    func addInput(_ input: AVCaptureDeviceInput) {
        configurePreset(input)
        if session.canAddInput(input) {
            session.addInput(input)
            DispatchQueue.main.async {
                self.delegate?.camera(self, didChangeInput: input)
            }
        }
    }
    
    func configurePreset(_ input: AVCaptureDeviceInput) {
        for asset in preferredPresets {
            if input.device.supportsSessionPreset(asset) && self.session.canSetSessionPreset(asset) {
                self.session.sessionPreset = asset
                return
            }
        }
    }
    
    fileprivate func start() {
        setupDevices()
        
        guard let input = backCamera, let output = photoOutput else {
            return
        }
        
        addInput(input)
        
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        sessionQueue.async {
            self.session.startRunning()
            DispatchQueue.main.async {
                self.delegate?.cameraDidStart(self)
            }
        }
    }
    
    func stop() {
        self.session.stopRunning()
    }
    
    func switchCamera(_ completion: (() -> Void)? = nil) {
        guard let currentInput = currentInput
            else {
                completion?()
                return
        }
        sessionQueue.async {
            guard let input = (currentInput == self.backCamera) ? self.frontCamera : self.backCamera else {
                DispatchQueue.main.async {
                    completion?()
                }
                return
            }
            
            self.configure {
                self.session.removeInput(currentInput)
                self.addInput(input)
            }
            
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    
    func switchFlashMode(_ mode: AVCaptureDevice.FlashMode) {
        guard let _ = currentInput?.device , photoOutput?.supportedFlashModes.contains(mode) ?? false else {
            return
        }
        flashMode = mode
    }
    
    func focus(_ point: CGPoint) {
        guard let device = currentInput?.device , device.isFocusModeSupported(AVCaptureDevice.FocusMode.locked) else {
            return
        }
        sessionQueue.async {
            self.lock {
                device.focusPointOfInterest = point
            }
        }
    }
    
    func lock(_ block: () -> Void) {
        if let device = currentInput?.device , (try? device.lockForConfiguration()) != nil {
            block()
            device.unlockForConfiguration()
        }
    }
    
    // MARK: - Configure
    func configure(_ block: () -> Void) {
        session.beginConfiguration()
        block()
        session.commitConfiguration()
    }
    
    func takePhoto(_ previewLayer: AVCaptureVideoPreviewLayer, location: CLLocation?, completion: @escaping ((PHAsset?) -> Void)) {
        guard let connection = photoOutput?.connection(with: .video) else { return }
        
        connection.videoOrientation = PSUtils.videoOrientation()
        
        self.location = location
        self.completion = completion
        sessionQueue.async {
            let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey:AVVideoCodecJPEG])
            settings.flashMode = self.flashMode
            self.photoOutput?.capturePhoto(with: settings, delegate: self)
        }
    }
    
    func savePhoto(_ image: UIImage, location: CLLocation?, completion: @escaping ((PHAsset?) -> Void)) {
        var localIdentifier: String?
        
        savingQueue.async {
            
            do {
                try PHPhotoLibrary.shared().performChangesAndWait {
                    let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                    localIdentifier = request.placeholderForCreatedAsset?.localIdentifier
                    request.creationDate = Date()
                    request.location = location
                }
                
                DispatchQueue.main.async {
                    if let localIdentifier = localIdentifier {
                        completion(PSUtils.fetchAsset(localIdentifier))
                    } else {
                        completion(nil)
                    }
                }
                
            } catch {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
}

extension PSCameraManager: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let error = error {
            print(error.localizedDescription)
        }
        if let sampleBuffer = photoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: photoSampleBuffer) {
            self.savePhoto(UIImage(data: dataImage)!, location: location, completion: completion!)
        }
    }
}


