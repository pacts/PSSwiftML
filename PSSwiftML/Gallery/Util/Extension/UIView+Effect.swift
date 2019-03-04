//
//  UIView+Effect.swift
//  PSSwiftyML
//
//  Created by Aaron on 2019/1/28.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit

extension UIView {
    
    func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 1
    }
    
    func addRoundBorder() {
        layer.borderWidth = 1
        layer.borderColor = PSGalleryConfig.Grid.FrameView.borderColor.cgColor
        layer.cornerRadius = 3
        clipsToBounds = true
    }
    
    func quickFade(visible: Bool = true) {
        UIView.animate(withDuration: 0.1, animations: {
            self.alpha = visible ? 1 : 0
        })
    }
    
    func fade(visible: Bool) {
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = visible ? 1 : 0
        })
    }
}
