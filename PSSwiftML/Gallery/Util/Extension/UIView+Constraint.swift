//
//  UIView+Constraint.swift
//  PSSwiftyML
//
//  Created by Aaron on 2019/1/23.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit

extension UIView {
    
    @discardableResult
    func ps_makeConstraint(attribute: NSLayoutConstraint.Attribute,
                          toView: UIView? = nil,
                          on: NSLayoutConstraint.Attribute? = nil,
                          constant: CGFloat = 0,
                          priority: Float? = nil) -> NSLayoutConstraint? {
        
        guard let toView = toView ?? superview else {
            return nil
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        let on = on ?? attribute
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: attribute,
                                            relatedBy: .equal,
                                            toItem: toView,
                                            attribute: on,
                                            multiplier: 1,
                                            constant: constant)
        if let priority = priority {
            constraint.priority = UILayoutPriority(priority)
        }
        
        constraint.isActive = true
        
        return constraint
    }
    
    func ps_makeEdges(view: UIView? = nil) {
        ps_makeConstraint(attribute: .top, toView: view)
        ps_makeConstraint(attribute: .bottom, toView: view)
        ps_makeConstraint(attribute: .left, toView: view)
        ps_makeConstraint(attribute: .right, toView: view)
    }
    
    func ps_makeWidth(_ width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width))
    }
    
    func ps_makeHeight(_ height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height))
    }
    
    func ps_makeSize(_ size: CGSize) {
        ps_makeWidth(size.width)
        ps_makeHeight(size.height)
    }
    
    func ps_makeGreaterThanHeight(_ height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height))
    }
    
    func ps_makeHorizontalPadding(view: UIView? = nil, padding: CGFloat) {
        ps_makeConstraint(attribute: .left, toView: view, constant: padding)
        ps_makeConstraint(attribute: .right, toView: view, constant: -padding)
    }
    
    func ps_makeUpward(view: UIView? = nil) {
        ps_makeConstraint(attribute: .top, toView: view)
        ps_makeConstraint(attribute: .left, toView: view)
        ps_makeConstraint(attribute: .right, toView: view)
    }
    
    func ps_makeDownward(view: UIView? = nil) {
        ps_makeConstraint(attribute: .bottom, toView: view)
        ps_makeConstraint(attribute: .left, toView: view)
        ps_makeConstraint(attribute: .right, toView: view)
    }
    
    func ps_makeCenter(view: UIView? = nil) {
        ps_makeConstraint(attribute: .centerX, toView: view)
        ps_makeConstraint(attribute: .centerY, toView: view)
    }
}

struct Constraint {
    static func on(constraints: [NSLayoutConstraint]) {
        constraints.forEach {
            ($0.firstItem as? UIView)?.translatesAutoresizingMaskIntoConstraints = false
            $0.isActive = true
        }
    }
    
    static func on(_ constraints: NSLayoutConstraint ...) {
        on(constraints: constraints)
    }
}
