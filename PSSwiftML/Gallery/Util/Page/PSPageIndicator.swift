//
//  PSPageIndicator.swift
//  PSSwiftyML
//
//  Created by Aaron on 2019/1/24.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit

protocol PSPageIndicatorDelegate: class {
    func pageIndicator(_ pageIndicator: PSPageIndicator, didSelect index: Int)
}

class PSPageIndicator: UIView {

    let items: [String]
    var buttons: [UIButton]!
    lazy var indicator: UIImageView = {
        let iv = UIImageView(image: PSGalleryBundle.image("gallery_page_indicator"))
        addSubview(iv)
        return iv
    }()
    
    weak var delegate: PSPageIndicatorDelegate?
    
    required init(items: [String]) {
        self.items = items
        super.init(frame: .zero)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let width = bounds.size.width / CGFloat(buttons.count)
        for (i, button) in buttons.enumerated() {
            button.frame = CGRect(x: width * CGFloat(i),
                                  y: 0,
                                  width: width,
                                  height: bounds.size.height)
        }
        
        indicator.frame.size = CGSize(width: width / 1.5, height: 4)
        indicator.frame.origin.y = bounds.size.height - indicator.frame.size.height
        
        if indicator.frame.origin.x == 0 {
            select(index: 0)
        }
    }
    private func setup() {
        buttons = items.map {
            let btn = self.buttonWithTitle($0)
            addSubview(btn)
            return btn
        }
    }
    
    private func buttonWithTitle(_ title: String) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.setTitle(title, for: UIControl.State())
        btn.setTitleColor(PSGalleryConfig.PageIndicator.textColor, for: UIControl.State())
        btn.setTitleColor(UIColor.gray, for: .highlighted)
        btn.backgroundColor = PSGalleryConfig.PageIndicator.backgroundColor
        btn.addTarget(self, action: #selector(buttonTouched(_:)), for: .touchUpInside)
        btn.titleLabel?.font = buttonFont(false)
        
        return btn
    }
    
    @objc func buttonTouched(_ button: UIButton) {
        let index = buttons.index(of: button) ?? 0
        delegate?.pageIndicator(self, didSelect: index)
        select(index: index)
    }
    
    func select(index: Int, animated: Bool = true) {
        for (i, b) in buttons.enumerated() {
            b.titleLabel?.font = buttonFont(i == index)
        }
        
        UIView.animate(withDuration: animated ? 0.25 : 0.0,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.5,
                       options: .beginFromCurrentState,
                       animations: {
                        self.indicator.center.x = self.buttons[index].center.x },
                       completion: nil)
    }
    
    func buttonFont(_ selected: Bool) -> UIFont {
        return selected ? PSGalleryConfig.Font.Main.bold.withSize(14) : PSGalleryConfig.Font.Main.regular.withSize(14)
    }
}
