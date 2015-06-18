//
//  InformationPostingController.swift
//  On The Map
//
//  Created by Johan Smet on 17/06/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import UIKit
import Foundation

class InformationPostingController: UIViewController {
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // outlets
    //

    @IBOutlet weak var containerLocation: UIView!
    @IBOutlet weak var containerLink: UIView!
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController overrides
    //
    
    override func viewDidLoad() {
        
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // actions
    //
    
    @IBAction func cancelPostFromLocation(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelPostFromLink(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func findOnMap(sender: AnyObject) {
        containerLocation.hidden = true
        containerLink.hidden = false
    }

    @IBAction func submitLocation(sender: AnyObject) {
    }
    
}

