//
//  PatienceOverlay.swift
//  On The Map
//
//  Created by Johan Smet on 08/07/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit

func createPatienceOverlay(topMessage : String, bottomMessage : String) -> UIView {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    // create a semi-transparent view the size of the entire screen
    let overlay = UIView(frame: appDelegate.window!.screen.bounds)
    overlay.opaque = false
    overlay.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
    
    // add an activity indicator in the center
    let activity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    activity.center = CGPointMake(overlay.frame.size.width / 2, overlay.frame.size.height / 2)
    activity.hidden = false
    activity.startAnimating()
    overlay.addSubview(activity)

    // add a label above the activity indicator
    let labelTop = UILabel()
    labelTop.text = topMessage
    labelTop.textColor = UIColor.whiteColor()
    labelTop.sizeToFit()
    labelTop.center = CGPointMake(overlay.frame.size.width / 2, overlay.frame.size.height / 2 - activity.frame.height)
    overlay.addSubview(labelTop)

    // add a label below the activity indicator
    let labelBottom = UILabel()
    labelBottom.text = bottomMessage
    labelBottom.textColor = UIColor.whiteColor()
    labelBottom.sizeToFit()
    labelBottom.center = CGPointMake(overlay.frame.size.width / 2, overlay.frame.size.height / 2 + activity.frame.height)
    overlay.addSubview(labelBottom)

    // add the view to the window
    appDelegate.window!.addSubview(overlay)
    
    return overlay
}