//
//  PSVideoLibrary.swift
//  PSSwiftyML
//
//  Created by Aaron on 2019/2/3.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit
import Photos

class PSVideoLibrary {
    
    var items: [PSVideo] = []
    var fetchResults: PHFetchResult<PHAsset>?
    
    init() {}
    
    func reload(_ completion: @escaping () -> Void) {
        DispatchQueue.global().async {
            self.reloadSync()
            DispatchQueue.main.async {
                completion()
            }
        }
    }

    fileprivate func reloadSync() {
        items = []
        fetchResults = PHAsset.fetchAssets(with: .video, options: PSUtils.fetchOptions())
        fetchResults?.enumerateObjects({ (asset, _, _) in
            self.items.append(PSVideo(asset: asset))
        })
    }
}
