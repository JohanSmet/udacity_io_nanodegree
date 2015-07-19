//
//  MainController.swift
//  On The Map
//
//  Created by Johan Smet on 16/06/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import UIKit
import Foundation

protocol AppDataTab {
    func refreshData()
}

class MainController: UITabBarController {
   
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController overrides
    //
    
    override func viewDidLoad() {
        
        // left navigation bar items
        let buttonLogout = UIBarButtonItem(title: NSLocalizedString("conLogout", comment: "Logout"), style: .Plain, target: self, action: "logout")
        self.navigationItem.setLeftBarButtonItems([buttonLogout], animated: true)
        
        // right navigation bar items
        let buttonRefresh = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refreshData")
        let buttonPost = UIBarButtonItem(image: UIImage(named: AssetIcons.Pin), style: .Plain, target: self, action: "postPin")
        self.navigationItem.setRightBarButtonItems([buttonRefresh, buttonPost], animated: true)
        
        // start loading the data of the application
        refreshData()
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // actions
    //
    
    func refreshData() {
        
        var patienceOverlay : UIView? = createPatienceOverlay(NSLocalizedString("conPleaseWait", comment:"Please wait"),
                                                              NSLocalizedString("conLoadingData", comment:"Loading data"))
        
        DataLoader.loadData() { error in
            
            if let overlay = patienceOverlay {
                overlay.removeFromSuperview()
                patienceOverlay = nil
            }
            
            if let errorMsg = error {
                alertOkAsync(self, errorMsg)
            } else {
                // refresh the active tab
                if let tab = self.selectedViewController as? AppDataTab {
                    tab.refreshData()
                }
            }
        }
        
    }
    
    func postPin() {
        performSegueWithIdentifier(ViewSegues.InformationPosting, sender: self)
    }
    
    func logout() {
        createPatienceOverlay(NSLocalizedString("conPleaseWait", comment: "Please wait"),
                              NSLocalizedString("conLogoutInProgress", comment: "Logout in progress"))
        
        LoginService.logout() { error in
            if let errorMsg = error {
                alertOkAsync(self, errorMsg)
            } else {
                self.performSegueWithIdentifier(ViewSegues.MainToLogin, sender: self)
            }
        }
    }

}
