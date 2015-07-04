//
//  LoginController.swift
//  On The Map
//
//  Created by Johan Smet on 16/06/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import UIKit
import Foundation

class LoginController: UIViewController,
                       UITextFieldDelegate {

    ///////////////////////////////////////////////////////////////////////////////////
    //
    // outlets
    //
    
    @IBOutlet weak var textEmail: UITextField!
    @IBOutlet weak var textPassword: UITextField!
    
    @IBOutlet weak var buttonLogin: UIButton!
    @IBOutlet weak var loginIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var labelError: UILabel!
    @IBOutlet weak var containerInput: UIView!
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    var keyboardFix : KeyboardFix?
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController overrides
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keyboardFix = KeyboardFix(viewController: self)
        
        // UI tweaks
        initTextField(textEmail)
        initTextField(textPassword)
        buttonLogin.layer.cornerRadius = 5
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // handle keyboard properly
        if let keyboardFix = self.keyboardFix {
            keyboardFix.activate()
        }
        
        // cleanup UI
        clearLoginError()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let keyboardFix = self.keyboardFix {
            keyboardFix.deactivate()
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITextFieldDelegate overrides
    //
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField == textEmail {
            // e-mail : jump to password field
            textPassword.becomeFirstResponder()
            return false
        }
        
        // dismiss the keyboard when the enter key is pressed
        textField.resignFirstResponder()
        return false
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // actions
    //
    
    @IBAction func signupForAccount(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: Urls.UDACITY_SIGNUP)!)
    }
    
    @IBAction func loginViaUdacity() {
        
        clearLoginError()
        
        if (!validateForm()) {
            return
        }
        
        uiLoginBegin()

        LoginService.loginViaUdacity(textEmail.text, password: textPassword.text) { apiError in
            self.uiLoginEnd()
            
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
    
    private func initTextField(textField : UITextField) {
        textField.delegate = self
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
    }
    
    private func uiLoginBegin() {
        dispatch_async(dispatch_get_main_queue(), {
            self.loginIndicator.hidden = false
            self.buttonLogin.enabled = false
        })
    }
    
    private func uiLoginEnd() {
        dispatch_async(dispatch_get_main_queue(), {
            self.loginIndicator.hidden = true
            self.buttonLogin.enabled = true
        })
    }
    
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
            animShakeHorizontal(self.containerInput)
        })
    }
}