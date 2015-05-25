//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Johan Smet on 25/05/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {
    
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // public data
    //
    
    var memeImage : UIImage!
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // outlets
    //

    @IBOutlet weak var imageView: UIImageView!
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController overrides
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = memeImage
    }

}

