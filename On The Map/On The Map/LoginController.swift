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
    
    @IBOutlet weak var buttonLogin: UIButton!
    
    @IBOutlet weak var labelError: UILabel!
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController overrides
    //
    
    override func viewDidLoad() {
        // UI tweaks
        buttonLogin.layer.cornerRadius = 5
    }
    
    override func viewDidAppear(animated: Bool) {
        clearLoginError()
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // actions
    //
    
    @IBAction func loginViaUdacity() {
        
        clearLoginError()
        
        if (!validateForm()) {
            return
        }
        
        UdacityApiClient.instance().createSession(textEmail.text, password: textPassword.text) { apiError in
            if let error = apiError {
                self.showLoginErrorSync(error)
            } else {
                self.completeLogin()
            }
        }
        
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // utility functions
    //
    
    private func validateForm() -> Bool {
        
        if textEmail.text.isEmpty && textPassword.text.isEmpty {
            showLoginError("Email and password cannot be empty !")
            return false;
        } else if textEmail.text.isEmpty {
            showLoginError("Email cannot be empty !")
            return false;
        } else if textPassword.text.isEmpty {
            showLoginError("Password cannot be empty !")
            return false;
        }
        
        return true;
    }
    
    private func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            self.performSegueWithIdentifier(ViewSeques.LoginToMain, sender: self)
        })
    }
    
    private func clearLoginError() {
        labelError.text = ""
        labelError.hidden = true
    }
    
    private func showLoginError (errorMessage : String) {
        labelError.text = errorMessage
        labelError.hidden = false
    }
    
    private func showLoginErrorSync(errorMessage : String) {
        dispatch_async(dispatch_get_main_queue(), {
            self.showLoginError(errorMessage)
        })
    }

}