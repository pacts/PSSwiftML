//
//  PSPSVideoEditing.swift
//  PSSwiftyML
//
//  Created by Aaron on 2019/1/24.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

public protocol PSVideoEditing: class {
    
    func crop(avAsset: AVAsset, completion: @escaping (URL?) -> Void)
    func edit(video: PSVideo, completion: @escaping (_ PSVideo: PSVideo?, _ tempPath: URL?) -> Void)
}

extension PSVideoEditing {
    
    public func process(video: PSVideo, completion: @escaping (_ video: PSVideo?, _ tempPath: URL?) -> Void) {
        video.fetchAVAsset { avAsset in
            guard let avAsset = avAsset else {
                completion(nil, nil)
                return
            }
            
            self.crop(avAsset: avAsset) { (outputURL: URL?) in
                guard let outputURL = outputURL else {
                    completion(nil, nil)
                    return
                }
                
                self.handle(outputURL: outputURL, completion: completion)
            }
        }
    }
    
    func handle(outputURL: URL, completion: @escaping (_ PSVideo: PSVideo?, _ tempPath: URL?) -> Void) {
        guard PSGalleryConfig.VideoEditor.savesEditedVideoToLibrary else {
            completion(nil, outputURL)
            return
        }
        
        var localIdentifier: String?
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL)
            localIdentifier = request?.placeholderForCreatedAsset?.localIdentifier
        }, completionHandler: { succeeded, info in
            if  let localIdentifier = localIdentifier,
                let asset = PSUtils.fetchAsset(localIdentifier) {
                completion(PSVideo(asset: asset), outputURL)
            } else {
                completion(nil, outputURL)
            }
        })
    }
}
