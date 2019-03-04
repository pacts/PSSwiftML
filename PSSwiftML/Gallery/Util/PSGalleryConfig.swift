//
//  PSGalleryConfig.swift
//  PSSwiftyML
//
//  Created by Aaron on 2019/1/23.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit
import AVFoundation

public struct PSGalleryConfig {

    public enum TabItem {
        case image
        case camera
        case video
    }
    
    public static var items: [TabItem] = [.image]
    public static var initialTab: TabItem?

    public struct PageIndicator {
        
        public static var backgroundColor: UIColor = UIColor(hex:0x00030A)
        public static var textColor: UIColor = UIColor.white
        
    }
    
    public struct Camera {
        
        public static var recordLocation: Bool = false
        public static var maxCount: Int = 0
        
        public struct ShutterButton {
            public static var numberColor: UIColor = UIColor(hex: 0x36383E)
        }
        
        public struct BottomContainer {
            public static var backgroundColor: UIColor = UIColor(hex: 0x17181C, alpha:0.8)
        }
        
        public struct StackView {
            public static let imageCount: Int = 4
        }
        
    }
    
    public struct Grid {
        
        public struct CloseButton {
            public static var tintColor: UIColor = UIColor.black
        }
        
        public struct ArrowButton {
            public static var tintColor: UIColor = UIColor.black
        }
        
        public struct FrameView {
            public static var fillColor: UIColor = UIColor(hex: 0x32333B)
            public static var borderColor: UIColor = UIColor(hex: 0x00EF9B)
        }
        
        struct Dimension {
            static let columnCount: CGFloat = 4
            static let cellSpacing: CGFloat = 2
        }
    }
    
    public struct EmptyView {
        public static var image: UIImage? = PSGalleryBundle.image("gallery_empty_view_image")
        public static var textColor: UIColor = UIColor(hex: 0x66768A)
    }
    
    public struct Permission {
        public static var image: UIImage? = PSGalleryBundle.image("gallery_permission_view_camera")
        public static var textColor: UIColor = UIColor(hex: 0x66768A)
        
        public struct Button {
            public static var textColor: UIColor = UIColor.white
            public static var highlightedTextColor: UIColor = UIColor.lightGray
            public static var backgroundColor = UIColor(hex: 0x28AAEC)
        }
    }
    
    public struct Font {
        
        public struct Main {
            public static var light: UIFont = UIFont.systemFont(ofSize: 1)
            public static var regular: UIFont = UIFont.systemFont(ofSize: 1)
            public static var bold: UIFont = UIFont.boldSystemFont(ofSize: 1)
            public static var medium: UIFont = UIFont.boldSystemFont(ofSize: 18)
        }
        
        public struct Text {
            public static var regular: UIFont = UIFont.systemFont(ofSize: 1)
            public static var bold: UIFont = UIFont.boldSystemFont(ofSize: 1)
            public static var semibold: UIFont = UIFont.boldSystemFont(ofSize: 1)
        }
    }
    
    public struct VideoEditor {
        
        public static var quality: String = AVAssetExportPresetHighestQuality
        public static var savesEditedVideoToLibrary: Bool = false
        public static var maximumDuration: TimeInterval = 15
        public static var portraitSize: CGSize = CGSize(width: 360, height: 640)
        public static var landscapeSize: CGSize = CGSize(width: 640, height: 360)
    }
}
