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
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // actions
    //
    
    func editNewMeme() {
        self.performSegueWithIdentifier("memeEditorSegue", sender: self)
    }
    
}

