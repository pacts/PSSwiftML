//
//  PSOnce.swift
//  PSSwiftyML
//
//  Created by Aaron on 2019/1/23.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit

class PSOnce {
    
    var already: Bool = false
    
    func run(_ closure: () -> Void) {
        
        guard !already else {
            return
        }
        closure()
        already = true
    }

}
