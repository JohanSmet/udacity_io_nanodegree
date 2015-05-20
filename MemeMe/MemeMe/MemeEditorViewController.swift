//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Johan Smet on 14/05/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController,
                                UIImagePickerControllerDelegate,
                                UINavigationControllerDelegate,
                                UITextFieldDelegate {

    ///////////////////////////////////////////////////////////////////////////////////
    //
    // outlets
    //
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    @IBOutlet weak var memeImage: UIImageView!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // constants
    //
    
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -2
    ]
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController overrides
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(animated: Bool) {
        
        // disable the camera button when no camera is available
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
    
        // only enable the share button when the meme is complete
        shareButton.enabled = memeIsComplete()
        
        // make sure the meme textfields are formatted appropriately
        formatMemeTextField(topText)
        formatMemeTextField(bottomText)
        
        // subscribe to keyboard notifications to scroll the current textfield to the visible portion of the screen
        subscribeToKeyboardNotifications()
    }
    
    override func viewDidDisappear(animated: Bool) {
        unsubscribeFromKeyboardNotifications()
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIImagePickerControllerDelegate overrides
    //
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {

        // show the image picked by the user
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            memeImage.image = image
        }
        
        // close the image picker
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // close the image picker
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITextFieldDelegate overrides
    //
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeTextField = textField
    }

    func textFieldDidEndEditing(textField: UITextField) {
        activeTextField = nil
    }
    
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // actions
    //
    
    @IBAction func pickImageFromCamera(sender: UIBarButtonItem) {
        // setup the image picker
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        
        // present the image picker
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickImageFromAlbum(sender: AnyObject) {
        // setup the image picker
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        // present the image picker
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func cancelEditor(sender: AnyObject) {
        self.view.frame.origin.y -= 5
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // utility functions
    //
    
    private func memeIsComplete() -> Bool {
        // TODO: complete == image + two text fields filled in
        return false
    }

    private func formatMemeTextField(p_field: UITextField) {
        p_field.defaultTextAttributes = memeTextAttributes
        p_field.textAlignment = NSTextAlignment.Center
        p_field.autocapitalizationType = UITextAutocapitalizationType.AllCharacters
        p_field.borderStyle = UITextBorderStyle.None
        // attributed placeholder
        var f_attrs = memeTextAttributes
        f_attrs[NSForegroundColorAttributeName] = UIColor.grayColor()
        p_field.attributedPlaceholder = NSAttributedString(string:p_field.placeholder ?? "", attributes: f_attrs)
    }

    private func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    private func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        // keyboard height
        let kbHeight = getKeyboardHeight(notification)
        
        // update the insets of the scroll view
        let contentInsets:UIEdgeInsets  = UIEdgeInsetsMake(0.0, 0.0, kbHeight, 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets

        // check if the current control is outside the view or not
        if let activeTextField = self.activeTextField {
        
            var aRect: CGRect = self.view.frame
            aRect.size.height -= kbHeight
        
            if (!CGRectContainsPoint(aRect, activeTextField.frame.origin) ) {
                let scrollPoint:CGPoint = CGPointMake(0.0, activeTextField.frame.origin.y - kbHeight)
                scrollView.setContentOffset(scrollPoint, animated: true)
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let kbHeight = getKeyboardHeight(notification)
     
        // reset the insets of the scroll view
        let contentInsets:UIEdgeInsets = UIEdgeInsetsZero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    private func getKeyboardHeight(notification : NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // member variables
    //
    
    var activeTextField : UITextField? = nil
    
}

