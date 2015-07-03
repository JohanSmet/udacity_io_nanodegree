//
//  KeyboardFix.swift
//  On The Map
//
//  Created by Johan Smet on 03/07/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit

class KeyboardFix : NSObject {
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    private let viewController : UIViewController
    
    private var keyboardAdjusted : Bool     = false
    private var keyboardOffset   : CGFloat  = 0
    
    private var tapRecognizer    : UITapGestureRecognizer?
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // initialisers
    //
    
    init (viewController : UIViewController) {
        
        self.viewController = viewController
        super.init()
        
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // public interface
    //
    
    func activate() {
        // keyboard notifications
        subscribeToKeyboardNotifications()
        
        // hide keyboard when the view is tapped
        if tapRecognizer == nil {
            tapRecognizer = UITapGestureRecognizer(target: self, action : "handleTap")
            tapRecognizer?.numberOfTapsRequired = 1
        }
        
        viewController.view.addGestureRecognizer(tapRecognizer!)
    }
    
    func deactivate() {
        unsubscribeFromKeyboardNotifications()
        viewController.view.removeGestureRecognizer(tapRecognizer!)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // scroll the view when the keyboard (dis)appears
    //
    
    private func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    private func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if keyboardAdjusted == false {
            keyboardOffset = getKeyboardHeight(notification) / 2
            viewController.view.superview?.frame.origin.y -= keyboardOffset
            keyboardAdjusted = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if keyboardAdjusted == true {
            viewController.view.superview?.frame.origin.y += keyboardOffset
            keyboardAdjusted = false
        }
    }
    
    private func getKeyboardHeight(notification : NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // tap recognizer
    //
    
    func handleTap() {
        viewController.view.endEditing(true)
    }
}
