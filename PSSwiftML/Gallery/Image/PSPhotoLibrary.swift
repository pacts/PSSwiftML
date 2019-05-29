//
//  PSPhotoLibrary.swift
//  PSSwiftyML
//
//  Created by Aaron on 2019/1/28.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit
import Photos

class PSPhotoLibrary {
    var albums: [PSAlbum] = []
    var albumsFetchResults = [PHFetchResult<PHAssetCollection>]()

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
        let types: [PHAssetCollectionType] = [.smartAlbum, .album]
        
        albumsFetchResults = types.map {
            return PHAssetCollection.fetchAssetCollections(with: $0,
                                                           subtype: .any,
                                                           options: nil)
        }
        
        for result in albumsFetchResults {
            result.enumerateObjects { (collection, _, _) in
                let album = PSAlbum(collection: collection)
                album.reload()
                
                if !album.items.isEmpty {
                    self.albums.append(album)
                }
            }
        }
        
        if let index = albums.firstIndex(where: { $0.collection.assetCollectionSubtype == . smartAlbumUserLibrary }) {
            albums.moveToFirst(index)
        }
    }
}
