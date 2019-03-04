//
//  PSGalleryPermissionController.swift
//  PSSwiftyML
//
//  Created by Aaron on 2019/1/23.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit


protocol PSPermissionControllerDelegate: class {
    
    func permissionControllerDidFinish(_ controller: PSGalleryPermissionController)
    
}

class PSGalleryPermissionController: UIViewController {

    private lazy var permissionView: PSGalleryPermissionView = {
        let v = PSGalleryPermissionView()
        view.addSubview(v)
        return v
    }()
    
    weak var delegate: PSPermissionControllerDelegate?

    private let once = PSOnce()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        once.run {
            self.authorize()
        }
    }
    
    private func setup() {
        permissionView.closeButton.addTarget(self,
                                             action: #selector(close),
                                             for: .touchUpInside)
        permissionView.settingButton.addTarget(self,
                                            action:#selector(setting),
                                               for: .touchUpInside)
        permissionView.ps_makeEdges()
    }
    
    private func authorize() {
        
        if PSGalleryPermission.PhotoLibrary.status == .notDetermined {
            PSGalleryPermission.PhotoLibrary.request { [weak self] in
                self?.authorize()
            }
            
            return
        }
        
        if PSGalleryPermission.Camera.needsPermission && PSGalleryPermission.Camera.status == .notDetermined {
            PSGalleryPermission.Camera.request { [weak self] in
                self?.authorize()
            }
            
            return
        }
        
        DispatchQueue.main.async {
            self.delegate?.permissionControllerDidFinish(self)
        }
    }
    
    @objc private func setting() {
        DispatchQueue.main.async {
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL, options:[:], completionHandler: { (completion) in})
            }
        }
    }
    
    @objc private func close() {
        PSEventHub.shared.close?()
    }
}
