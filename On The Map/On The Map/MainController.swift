//
//  MainController.swift
//  On The Map
//
//  Created by Johan Smet on 16/06/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import UIKit
import Foundation

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
        let buttonPost = UIBarButtonItem(title: "Pin", style: UIBarButtonItemStyle.Plain, target: self, action: "postPin")
        self.navigationItem.setRightBarButtonItems([buttonRefresh, buttonPost], animated: true)

    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // actions
    //
    
    func refreshData() {
        
    }
    
    func postPin() {
        performSegueWithIdentifier(ViewSeques.InformationPosting, sender: self)
    }
    
    func logout() {
        
    }

}
