//
//  UIScrollView+ContentOffset.swift
//  PSSwiftyML
//
//  Created by Aaron on 2019/1/28.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit

extension UIScrollView {
    
    func scrollToTop() {
        setContentOffset(CGPoint.zero, animated: false)
    }
    
    func updateBottomInset(_ value: CGFloat) {
        var inset = contentInset
        inset.bottom = value
        contentInset = inset
        scrollIndicatorInsets = inset
    }
}
