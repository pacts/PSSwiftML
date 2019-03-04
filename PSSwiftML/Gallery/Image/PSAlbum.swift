//
//  PSAlbum.swift
//  PSSwiftyML
//
//  Created by Aaron on 2019/1/24.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit
import Photos

class PSAlbum: NSObject {
    
    let collection: PHAssetCollection
    var items: [PSImage] = []
    
    init(collection: PHAssetCollection) {
        self.collection = collection
    }
    
    func reload() {
        items = []
        
        let itemsFetchResult = PHAsset.fetchAssets(in: collection, options: PSUtils.fetchOptions())
        
        itemsFetchResult.enumerateObjects({ (asset, count, stop) in
            if asset.mediaType == .image {
                self.items.append(PSImage(asset: asset))
            }
        })
    }

}
