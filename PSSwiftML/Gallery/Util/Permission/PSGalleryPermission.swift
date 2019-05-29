//
//  PSGalleryPermission.swift
//  PSSwiftyML
//
//  Created by Aaron on 2019/1/23.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

struct PSGalleryPermission {
    
    enum Status {
        case notDetermined
        case restricted
        case denied
        case authorized
    }
    
    /// PhotoLibrary Permission
    struct PhotoLibrary {
        
        static var status: Status {
            
            switch PHPhotoLibrary.authorizationStatus() {
                
            case .notDetermined:
                return .notDetermined
                
            case .restricted:
                return .restricted
                
            case .denied:
                return .denied
                
            case .authorized:
                return .authorized
                
            @unknown default:
                return .notDetermined
            }
        }
        
        static func request(_ completion: @escaping () -> Void) {
            
            PHPhotoLibrary.requestAuthorization { status in
                completion()
            }
        }
    }
    
    /// - Camera Permission
    struct Camera {
        
        static var needsPermission: Bool {
            return PSGalleryConfig.items.firstIndex(of: .camera) != nil
        }
        
        static var status: Status {
            
            switch AVCaptureDevice.authorizationStatus(for: .video) {
                
            case .notDetermined:
                return .notDetermined
                
            case .restricted:
                return .restricted
                
            case .denied:
                return .denied
                
            case .authorized:
                return .authorized
                
            @unknown default:
                return .notDetermined
            }
        }
        
        static func request(_ completion: @escaping () -> Void) {
            
            AVCaptureDevice.requestAccess(for: .video) { status in
                completion()
            }
        }
    }
}
