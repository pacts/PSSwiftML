//
//  UIView+Layout.swift
//  PSSwiftyML
//
//  Created by Aaron on 2019/1/23.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit

extension UIView {
    
    // MARK: - 常用位置属性
    public var x: CGFloat{
        get{
            return self.frame.origin.x
        }
        set{
            var r = self.frame
            r.origin.x = newValue
            self.frame = r
        }
    }
    
    public var y: CGFloat{
        get{
            return self.frame.origin.y
        }
        set{
            var r = self.frame
            r.origin.y = newValue
            self.frame = r
        }
    }
    
    public var left: CGFloat{
        get{
            return self.frame.origin.x
        }
        set{
            var r = self.frame
            r.origin.x = newValue
            self.frame = r
        }
    }
    
    public var right: CGFloat{
        get{
            return self.x + self.w
        }
        set{
            var r = self.frame
            r.origin.x = newValue - frame.size.width
            self.frame = r
        }
    }
    
    
    public var bottom: CGFloat{
        get{
            return self.y + self.h
        }
        set{
            var r = self.frame
            r.origin.y = newValue - frame.size.height
            self.frame = r
        }
    }
    
    public var centerX : CGFloat{
        get{
            return self.center.x
        }
        set{
            self.center = CGPoint(x: newValue, y: self.center.y)
        }
    }
    
    public var centerY : CGFloat{
        get{
            return self.center.y
        }
        set{
            self.center = CGPoint(x: self.center.x, y: newValue)
        }
    }
    
    
    public var w: CGFloat{
        get{
            return self.frame.size.width
        }
        set{
            var r = self.frame
            r.size.width = newValue
            self.frame = r
        }
    }
    
    
    public var h: CGFloat{
        get{
            return self.frame.size.height
        }
        set{
            var r = self.frame
            r.size.height = newValue
            self.frame = r
        }
    }
    
    public var origin: CGPoint{
        get{
            return self.frame.origin
        }
        set{
            self.x = newValue.x
            self.y = newValue.y
        }
    }
    
    public var size: CGSize{
        get{
            return self.frame.size
        }
        set{
            self.w = newValue.width
            self.h = newValue.height
        }
    }
}

/// 判断是否为刘海屏幕
func SafeAreaTop() ->CGFloat
{
    if #available(iOS 11.0, *) {
        return UIApplication.shared.windows[0].safeAreaInsets.top > 0 ? UIApplication.shared.windows[0].safeAreaInsets.top : 20
    } else {
        return 20
    }
}

func SafeAreaBottom() ->CGFloat {
    if #available(iOS 11.0, *) {
        return UIApplication.shared.windows[0].safeAreaInsets.bottom
    } else {
        return 0
    }
}
