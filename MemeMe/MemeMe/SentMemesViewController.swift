//
//  SentMemesViewController.swift
//  MemeMe
//
//  Created by Johan Smet on 22/05/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//


import UIKit

class SentMemesViewController: UITabBarController {
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController overrides
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigation bar items
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "editNewMeme")
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // show the editor if no memes are present in the model
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if appDelegate.memes.isEmpty {
            editNewMeme()
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // actions
    //
    
    func editNewMeme() {
        self.performSegueWithIdentifier("memeEditorSegue", sender: self)
    }
    
}

