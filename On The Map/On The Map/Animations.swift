//
//  Animations.swift
//  On The Map
//
//  Created by Johan Smet on 03/07/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit

func animShakeHorizontal(view : UIView) {
    
    UIView.animateWithDuration(0.2, delay: 0, options: .Repeat | .Autoreverse | .CurveEaseInOut, animations: {
        UIView.setAnimationRepeatCount(3)
        view.center.x += 4
    }, completion: nil)
    
}