//
//  User.swift
//  On The Map
//
//  Created by Johan Smet on 30/06/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import Foundation

struct User {
   
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // properties
    //
    
    var userId      : String;
    var firstName   : String;
    var lastName    : String;
    
    var linkedInUrl : String?;
    var location    : String?;
    var mediaUrl    : String?;
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // initialisers
    //
    
    init(userId : String, firstName : String, lastName : String) {
        self.userId     = userId
        self.firstName  = firstName
        self.lastName   = lastName
    }
}