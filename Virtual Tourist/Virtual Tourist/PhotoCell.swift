//
//  PhotoCell.swift
//  Virtual Tourist
//
//  Created by Johan Smet on 12/08/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit

class PhotoCell : UICollectionViewCell {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var overlay: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // change the appearance of the cell
    //
    
    func stateWaiting() {
        image.hidden = true
        
        overlay.backgroundColor = UIColor(red: 81.0/255, green: 137.0/255, blue: 180.0/255, alpha: 1.0)
        overlay.alpha           = 1.0
        overlay.hidden          = false
        
        activityIndicator.hidden = false
    }
    
    func stateImage(path : String) {
        
        activityIndicator.hidden = true
        overlay.hidden           = true
       
        if let imgData = UIImage(contentsOfFile: path) {
            image.image  = imgData
            image.hidden = false
        }
    }
    
    func stateSelected() {
        
        overlay.backgroundColor  = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.8)
        overlay.alpha            = 0.8
        overlay.hidden           = false
        
        activityIndicator.hidden = true
    }
    
    func stateDeselected() {
        
        overlay.hidden           = true
        
    }
}