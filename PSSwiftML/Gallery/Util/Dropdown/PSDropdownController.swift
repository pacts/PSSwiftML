//
//  PSDropdownController.swift
//  PSSwiftyML
//
//  Created by Aaron on 2019/1/24.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit
import Photos

protocol PSDropdownControllerDelegate: class {
    
    func dropdownController(_ controller: PSDropdownController, didSelect album: PSAlbum)
    
}

class PSDropdownController: UIViewController {

    lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.tableFooterView = UIView()
        tv.separatorStyle = .none
        tv.rowHeight = 84
        tv.dataSource = self
        tv.delegate = self
        
        view.addSubview(tv)
        return tv
    }()
    
    lazy var blurView: UIVisualEffectView = {
        let vev = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        return vev
    }()
    
    var animating: Bool = false
    var expanding: Bool = false
    var selectedIndex: Int = 0
    
    var albums: [PSAlbum] = [] {
        didSet {
            selectedIndex = 0
        }
    }
    
    var expandedTopConstraint: NSLayoutConstraint?
    var collapsedTopConstraint: NSLayoutConstraint?
    
    weak var delegate: PSDropdownControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }

    private func setup() {
        view.backgroundColor = .clear
        
        tableView.backgroundColor = .clear
        tableView.backgroundView = blurView
        tableView.register(PSAlbumCell.self,
                           forCellReuseIdentifier: String(describing: PSAlbumCell.self))
        
        tableView.ps_makeEdges()
        
    }
    
    func toggle() {
        guard !animating else { return }
        
        animating = true
        expanding = !expanding
        
        if expanding {
            collapsedTopConstraint?.isActive = false
            expandedTopConstraint?.isActive = true
        } else {
            expandedTopConstraint?.isActive = false
            collapsedTopConstraint?.isActive = true
        }
        
        UIView.animate(withDuration: 0.25, delay: 0,
                       options: UIView.AnimationOptions(), animations: {
            self.view.superview?.layoutIfNeeded()
        }, completion: { finished in
            self.animating = false
        })
    }
}

extension PSDropdownController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PSAlbumCell.self), for: indexPath)
            as! PSAlbumCell
        let album = albums[(indexPath as NSIndexPath).row]
        cell.configure(album)
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let album = albums[(indexPath as NSIndexPath).row]
        delegate?.dropdownController(self, didSelect: album)
        
        selectedIndex = (indexPath as NSIndexPath).row
        tableView.reloadData()
    }
}
