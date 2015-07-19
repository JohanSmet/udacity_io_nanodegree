//
//  BrowseLinkController.swift
//  On The Map
//
//  Created by Johan Smet on 14/07/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit

protocol BrowseLinkResultDelegate : NSObjectProtocol {
    func selectedURL(urlString : String)
}

class BrowseLinkController: UIViewController,
                            UITextFieldDelegate,
                            UIWebViewDelegate {
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // outlets
    //
   
    @IBOutlet weak var linkUrlText: UITextField!
    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var useLinkButton: UIBarButtonItem!
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    var link : String = ""
    var delegate : BrowseLinkResultDelegate!
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController overrides
    //
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // setup webview
        webView.delegate = self
        backButton.enabled = false
        forwardButton.enabled = false
        
        // URL input
        linkUrlText.text = link
        linkUrlText.delegate = self
        
        browseToUrl()
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITextFieldDelegate overrides
    //
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if useLinkButton.enabled {
            browseToUrl()
        }
        return false
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        // create the new text
        var newText: NSString = textField.text
        newText = newText.stringByReplacingCharactersInRange(range, withString: string)
        
        // enable the "use this link" button if it represents a valid url
        useLinkButton.enabled = isValidUrl(newText as String)
        
        return true
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITextFieldDelegate overrides
    //
    
    func webViewDidFinishLoad(webView: UIWebView) {
        backButton.enabled = webView.canGoBack
        forwardButton.enabled = webView.canGoForward
        linkUrlText.text = webView.request!.URL?.absoluteString
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // actions
    //
    
    @IBAction func browserBack(sender: AnyObject) {
        webView.goBack()
    }
    
    @IBAction func browserNext(sender: AnyObject) {
        webView.goForward()
    }
    
    @IBAction func useLink(sender: AnyObject) {
        if let delegate = self.delegate {
            delegate.selectedURL(linkUrlText.text)
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelBrowse(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // helper functions
    //
    
    private func browseToUrl() {
        
        if let url = NSURL(string: linkUrlText.text) {
            let request = NSURLRequest(URL: url)
            webView.loadRequest(request)
        }
    }
}