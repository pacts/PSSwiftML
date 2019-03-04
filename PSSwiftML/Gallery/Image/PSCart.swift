//
//  PSCart.swift
//  PSSwiftyML
//
//  Created by Aaron on 2019/1/28.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit
import Photos

public protocol PSCartDelegate: class {
    
    func cart(_ cart: PSCart, didAdd image: PSImage, newlyTaken: Bool)
    func cart(_ cart: PSCart, didRemove image: PSImage)
    func cartDidReload(_ cart: PSCart)
    
}
public class PSCart {
    
    public var images: [PSImage] = []
    public var video: PSVideo?
    var delegates: NSHashTable<AnyObject> = NSHashTable.weakObjects()

    init() {}
    
    public func add(delegate: PSCartDelegate) {
        delegates.add(delegate)
    }
    
    public func add(_ image:PSImage, newlyToken: Bool = false) {
        guard !images.contains(image) else {
            return
        }
        
        images.append(image)
        
        for case let delegate as PSCartDelegate in delegates.allObjects {
            delegate.cart(self, didAdd: image, newlyTaken: newlyToken)
        }
    }
    
    public func remove(_ image: PSImage) {
        guard let index = images.index(of: image) else { return }
        
        images.remove(at: index)
        
        for case let delegate as PSCartDelegate in delegates.allObjects {
            delegate.cart(self, didRemove: image)
        }
    }
    
    public func reload(_ images: [PSImage]) {
        self.images = images
        
        for case let delegate as PSCartDelegate in delegates.allObjects {
            delegate.cartDidReload(self)
        }
    }
    
    public func reset() {
        video = nil
        images.removeAll()
        delegates.removeAllObjects()
    }
}
