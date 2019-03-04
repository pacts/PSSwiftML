//
//  PSEventHub.swift
//  PSSwiftyML
//
//  Created by Aaron on 2019/1/24.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit

class PSEventHub {
    
    static let shared = PSEventHub()
    
    var close: (() -> Void)?
    var doneWithImages: (() -> Void)?
    var doneWithVideos: (() -> Void)?
    var stackViewTouched: (() -> Void)?

    init() {}
}
