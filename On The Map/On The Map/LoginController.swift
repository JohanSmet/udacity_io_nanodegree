//
//  LoginController.swift
//  On The Map
//
//  Created by Johan Smet on 16/06/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import UIKit
import Foundation

class LoginController: UIViewController {

    ///////////////////////////////////////////////////////////////////////////////////
    //
    // outlets
    //
    
    @IBOutlet weak var textEmail: UITextField!
    @IBOutlet weak var textPassword: UITextField!
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController overrides
    //
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // actions
    //
    
    @IBAction func loginViaUdacity() {
        self.performSegueWithIdentifier(ViewSeques.LoginToMain, sender: self)
    }
}