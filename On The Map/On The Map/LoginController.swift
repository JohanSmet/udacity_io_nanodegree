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
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var textEmail: UITextField!
    @IBOutlet weak var textPassword: UITextField!
    
    @IBOutlet weak var buttonLogin: UIButton!
    @IBOutlet weak var buttonFacebook: UIButton!
    
    @IBOutlet weak var labelError: UILabel!
    @IBOutlet weak var containerInput: UIView!
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    var keyboardFix     : KeyboardFix?
    var patienceOverlay : UIView?
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController overrides
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keyboardFix = KeyboardFix(viewController: self, scrollView: scrollView)
        
        // UI tweaks
        styleTextField(textEmail, self)
        styleTextField(textPassword, self)
        styleButton(buttonLogin)
        styleButton(buttonFacebook)
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
    
    func textFieldDidBeginEditing(textField: UITextField) {
        keyboardFix?.setActiveControl(textField)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        keyboardFix?.setActiveControl(nil)
    }
    
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
                self.showLoginErrorAsync(error)
            } else {
                self.completeLogin()
            }
        }
    }
    
    @IBAction func loginViaFacebook(sender: AnyObject) {
        clearLoginError()
        
        uiLoginBegin()
        
        LoginService.loginViaFacebook() { apiError in
            self.uiLoginEnd()
            
            if let error = apiError {
                self.showLoginErrorAsync(error)
            } else {
                self.completeLogin()
            }
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // utility functions
    //
    
    private func uiLoginBegin() {
        dispatch_async(dispatch_get_main_queue(), {
            self.patienceOverlay = createPatienceOverlay(NSLocalizedString("conPleaseWait", comment: "Please wait"),
                                                         NSLocalizedString("conLoginInProgress", comment: "Login in progress"))
        })
    }
    
    private func uiLoginEnd() {
        dispatch_async(dispatch_get_main_queue(), {
            self.patienceOverlay?.removeFromSuperview()
            self.patienceOverlay = nil
        })
    }
    
    private func validateForm() -> Bool {
        
        if textEmail.text.isEmpty && textPassword.text.isEmpty {
            showLoginError(NSLocalizedString("conEmailPasswordMissing", comment: "Email and password cannot be empty !"))
            return false;
        } else if textEmail.text.isEmpty {
            showLoginError(NSLocalizedString("conEmailMissing", comment: "Email cannot be empty !"))
            return false;
        } else if textPassword.text.isEmpty {
            showLoginError(NSLocalizedString("conPasswordMissing", comment: "Password cannot be empty !"))
            return false;
        }
        
        return true;
    }
    
    private func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            self.performSegueWithIdentifier(ViewSegues.LoginToMain, sender: self)
        })
    }
    
    private func clearLoginError() {
        labelError.text = ""
        labelError.hidden = true
    }
    
    private func showLoginError (errorMessage : String) {
        labelError.text = errorMessage
        labelError.hidden = false
        animShakeHorizontal(labelError)
    }
    
    private func showLoginErrorAsync(errorMessage : String) {
        dispatch_async(dispatch_get_main_queue(), {
            self.showLoginError(errorMessage)
        })
    }
}