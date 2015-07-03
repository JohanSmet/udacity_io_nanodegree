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
    // outlets
    //
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController overrides
    //
    
    override func viewDidLoad() {
        
        // left navigation bar items
        let buttonLogout = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: "logout")
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
        
        DataLoader.loadData() { error in
            // XXX make this nicer
            if let errorMsg = error {
                var alert = UIAlertController(title: "Alert", message: errorMsg, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                // refresh the active tab
                if let tab = self.selectedViewController as? AppDataTab {
                    tab.refreshData()
                }
            }
        }
        
    }
    
    func postPin() {
        performSegueWithIdentifier(ViewSeques.InformationPosting, sender: self)
    }
    
    func logout() {
        
    }

}
