//
//  PSFlashButton.swift
//  PSSwiftyML
//
//  Created by Aaron on 2019/1/30.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit

class PSFlashButton: UIButton {

    struct FlashState {
        let title: String
        let image: UIImage
    }
    
    let states: [FlashState]
    var selectedIndex: Int = 0
    
    init(states: [FlashState]) {
        self.states = states
        super.init(frame: .zero)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        titleLabel?.font = PSGalleryConfig.Font.Text.semibold.withSize(12)
        imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        setTitleColor(.gray, for: .highlighted)
        
        select(index: selectedIndex)
    }
    
    @discardableResult func toggle() -> Int {
        selectedIndex = (selectedIndex + 1) % states.count
        select(index: selectedIndex)
        return selectedIndex
    }
    
    func select(index: Int) {
        
        guard index < states.count else {
            return
        }
        
        let state = states[index]
        setTitle(state.title, for: UIControl.State())
        setImage(state.image, for: UIControl.State())
    }
    
}
