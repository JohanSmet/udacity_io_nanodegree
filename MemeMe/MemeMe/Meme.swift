//
//  Meme.swift
//  MemeMe
//
//  Created by Johan Smet on 22/05/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit

struct Meme {
    
    let topText : String
    let bottomText : String
    let image : UIImage
    let memedImage : UIImage
    
    init(topText : String, bottomText : String, image : UIImage, memedImage : UIImage) {
        self.topText = topText
        self.bottomText = bottomText
        self.image = image
        self.memedImage = memedImage
    }
}