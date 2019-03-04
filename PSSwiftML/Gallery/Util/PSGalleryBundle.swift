//
//  PSGalleryBundle.swift
//  PSSwiftyML
//
//  Created by Aaron on 2019/1/23.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit

class PSGalleryBundle {

    static func image(_ named: String) -> UIImage? {
        let bundle = Bundle(path: "\(Bundle.main.bundlePath)/Gallery.bundle")
        return UIImage(named: named, in: bundle, compatibleWith: nil)
    }
}
