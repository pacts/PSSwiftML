//
//  AVAsset+Information.swift
//  PSSwiftyML
//
//  Created by Aaron on 2019/1/24.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit
import AVFoundation

extension AVAsset {
    
    fileprivate var ps_naturalSize: CGSize {
        return tracks(withMediaType: .video).first?.naturalSize ?? .zero
    }

    var ps_orientation: UIInterfaceOrientation {
        
        guard let transform = tracks(withMediaType: AVMediaType.video).first?.preferredTransform else {
            return .portrait
        }
        switch (transform.tx, transform.ty) {
            
        case (0, 0):
            return .landscapeRight
            
        case (ps_naturalSize.width, ps_naturalSize.height):
            return .landscapeLeft
            
        case (0, ps_naturalSize.width):
            return .portraitUpsideDown
            
        default:
            return .portrait
        }
        
    }
    var ps_isPortrait: Bool {
        
        let portraits: [UIInterfaceOrientation] = [.portrait, .portraitUpsideDown]
        return portraits.contains(ps_orientation)
        
    }
    
    var ps_correctSize: CGSize {
        
        return ps_isPortrait ? CGSize(width: ps_naturalSize.height, height: ps_naturalSize.width) : ps_naturalSize
        
    }
    
    var ps_fileSize: Double {
        
        guard let avURLAsset = self as? AVURLAsset else {
            return 0
        }
        
        var result: AnyObject?
        try? (avURLAsset.url as NSURL).getResourceValue(&result, forKey: URLResourceKey.fileSizeKey)
        
        if let result = result as? NSNumber {
            return result.doubleValue
        } else {
            return 0
        }
    }
    
    var ps_frameRate: Float {
        return tracks(withMediaType: AVMediaType.video).first?.nominalFrameRate ?? 30
    }
    
    var ps_videoDescription: CMFormatDescription? {
        let description = tracks(withMediaType: .video).first?.formatDescriptions.first
        guard let formatDesc = description else {
            return nil
        }
        
        return (formatDesc as! CMFormatDescription)
    }
    
    var ps_audioDescription: CMFormatDescription? {
        let description = tracks(withMediaType: .audio).first?.formatDescriptions.first
        guard let formatDesc = description else {
            return nil
        }
        
        return (formatDesc as! CMFormatDescription)
    }
}
