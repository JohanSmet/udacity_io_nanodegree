//
//  StudentInformation.swift
//  On The Map
//
//  Created by Johan Smet on 23/06/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import Foundation

struct StudentInformation {
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // properties
    //
    
    var objectId    : String
    var uniqueKey   : String
    var firstName   : String
    var lastName    : String
    var mapString   : String
    var mediaURL    : String
    var latitude    : Float
    var longitude   : Float
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // initializers
    //
    
    init(objectId : String, uniqueKey : String, firstName : String, lastName : String,
         mapString : String, mediaURL : String, latitude : Float, longitude : Float) {
        self.objectId   = objectId
        self.uniqueKey  = uniqueKey
        self.firstName  = firstName
        self.lastName   = lastName
        self.mapString  = mapString
        self.mediaURL   = mediaURL
        self.latitude   = latitude
        self.longitude  = longitude
    }
    
    init(values : [ String : String]) {
        self.objectId   = values["objectId"]!
        self.uniqueKey  = values["uniqueKey"]!
        self.firstName  = values["firstName"]!
        self.lastName   = values["lastName"]!
        self.mapString  = values["mapString"]!
        self.mediaURL   = values["mediaURL"]!
        self.latitude   = (values["latitude"]! as NSString).floatValue
        self.longitude  = (values["longitude"]! as NSString).floatValue
    }
    
}
