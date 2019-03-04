//
//  PSPageController.swift
//  PSSwiftyML
//
//  Created by Aaron on 2019/1/24.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit

protocol PSPageAware: class {
    func pageDidShow()
}

class PSPageController: UIViewController {
    
    let controllers: [UIViewController]
    
    lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.isPagingEnabled = true
        sv.showsHorizontalScrollIndicator = false
        sv.alwaysBounceHorizontal = false
        sv.bounces = false
        sv.delegate = self
        sv.backgroundColor = .white
        view.addSubview(sv)
        return sv
    }()
    
    lazy var scrollViewContentView: UIView = {
        let v = UIView()
        scrollView.addSubview(v)
        return v
    }()
    
    lazy var pageIndicator: PSPageIndicator = {
        let items = controllers.compactMap { $0.title }
        let indicator = PSPageIndicator(items: items)
        indicator.delegate = self
        view.addSubview(indicator)
        return indicator
    }()
    
    var selectedIndex: Int = 0
    
    let once = PSOnce()
    
    private var offsetY: CGFloat?
    // MARK: - Initialization
    
    required init(controllers: [UIViewController]) {
        self.controllers = controllers
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard scrollView.frame.size.width > 0 else {
            return
        }
        
        offsetY = scrollView.contentOffset.y
        once.run {
            DispatchQueue.main.async {
                self.scrollToAndSelect(index: self.selectedIndex, animated: false)
            }
            notify()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let index = selectedIndex
        
        coordinator.animate(alongsideTransition: { context in
            self.scrollToAndSelect(index: index, animated: context.isAnimated)
        }) { _ in }
        
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    // MARK: - Controls
 
    // MARK: - Setup
    
    func setup() {
        let usePageIndicator = controllers.count > 1
        if usePageIndicator {
            Constraint.on(
                pageIndicator.leftAnchor.constraint(equalTo: pageIndicator.superview!.leftAnchor),
                pageIndicator.rightAnchor.constraint(equalTo: pageIndicator.superview!.rightAnchor),
                pageIndicator.heightAnchor.constraint(equalToConstant: 40)
            )
            
            if #available(iOS 11, *) {
                Constraint.on(
                    pageIndicator.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
                )
            } else {
                Constraint.on(
                    pageIndicator.bottomAnchor.constraint(equalTo: pageIndicator.superview!.bottomAnchor)
                )
            }
        }
        
        scrollView.ps_makeUpward()
        if usePageIndicator {
            scrollView.ps_makeConstraint(attribute: .bottom, toView: pageIndicator, on: .top)
        } else {
            scrollView.ps_makeDownward()
        }
        
        scrollViewContentView.ps_makeEdges()
        
        for (i, controller) in controllers.enumerated() {
            addChild(controller)
            scrollViewContentView.addSubview(controller.view)
            controller.didMove(toParent: self)
            
            controller.view.ps_makeConstraint(attribute: .top)
            controller.view.ps_makeConstraint(attribute: .bottom)
            controller.view.ps_makeConstraint(attribute: .width, toView: scrollView)
            controller.view.ps_makeConstraint(attribute: .height, toView: scrollView)
            
            if i == 0 {
                controller.view.ps_makeConstraint(attribute: .left)
            } else {
                controller.view.ps_makeConstraint(attribute: .left, toView: self.controllers[i-1].view, on: .right)
            }
            
            if i == self.controllers.count - 1 {
                controller.view.ps_makeConstraint(attribute: .right)
            }
        }
    }
    
    // MARK: - Index
    
    fileprivate func scrollTo(index: Int, animated: Bool) {
        guard !scrollView.isTracking && !scrollView.isDragging && !scrollView.isZooming else {
            return
        }
        
        let point = CGPoint(x: scrollView.frame.size.width * CGFloat(index), y: scrollView.contentOffset.y)
        scrollView.setContentOffset(point, animated: animated)
    }
    
    fileprivate func scrollToAndSelect(index: Int, animated: Bool) {
        scrollTo(index: index, animated: animated)
        pageIndicator.select(index: index, animated: animated)
    }
    
    func updateAndNotify(_ index: Int) {
        guard selectedIndex != index else { return }
        
        selectedIndex = index
        notify()
    }
    
    func notify() {
        if let controller = controllers[selectedIndex] as? PSPageAware {
            controller.pageDidShow()
        }
    }
}

extension PSPageController: PSPageIndicatorDelegate {
    
    func pageIndicator(_ pageIndicator: PSPageIndicator, didSelect index: Int) {
        scrollTo(index: index, animated: false)
        updateAndNotify(index)
    }
}

extension PSPageController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.y = offsetY ?? scrollView.contentOffset.y
        guard scrollView.w > 0 else {
            return
        }
        
        let index = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
        pageIndicator.select(index: index)
        updateAndNotify(index)
    }
}
