//
//  ButtonStyle.swift
//  On The Map
//
//  Created by Johan Smet on 08/07/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit

func styleButton(button : UIButton) {
    button.layer.cornerRadius = 5
}

func styleTextField(textField : UITextField, delegate : UITextFieldDelegate?) {
    textField.delegate = delegate
    textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
}