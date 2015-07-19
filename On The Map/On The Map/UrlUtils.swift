//
//  UrlUtils.swift
//  On The Map
//
//  Created by Johan Smet on 19/07/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import Foundation

func isValidUrl(urlString : String) -> Bool {
    var error : NSError?
    let dataDetector = NSDataDetector(types: NSTextCheckingType.Link.rawValue, error: &error)
    
    if (dataDetector != nil && error == nil) {
        let range = NSMakeRange(0, count(urlString))
        let linkRange = dataDetector!.rangeOfFirstMatchInString(urlString, options: nil, range: range)
        
        if NSEqualRanges(range, linkRange) {
            return true
        }
    }
    
    return false
}