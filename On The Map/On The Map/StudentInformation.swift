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
    var latitude    : Double
    var longitude   : Double
    var occurances  : Int
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // initializers
    //
    
    init (uniqueKey : String, firstName : String, lastName : String) {
        self.objectId   = ""
        self.uniqueKey  = uniqueKey
        self.firstName  = firstName
        self.lastName   = lastName
        self.mapString  = ""
        self.mediaURL   = ""
        self.latitude   = 0
        self.longitude  = 0
        self.occurances = 1
    }
    
    init(objectId : String, uniqueKey : String, firstName : String, lastName : String,
         mapString : String, mediaURL : String, latitude : Double, longitude : Double) {
        self.objectId   = objectId
        self.uniqueKey  = uniqueKey
        self.firstName  = firstName
        self.lastName   = lastName
        self.mapString  = mapString
        self.mediaURL   = mediaURL
        self.latitude   = latitude
        self.longitude  = longitude
        self.occurances = 1
    }
    
    init(values : [ String : AnyObject]) {
        objectId   = values["objectId"]! as! String
        uniqueKey  = values["uniqueKey"]! as! String
        firstName  = values["firstName"]! as! String
        lastName   = values["lastName"]! as! String
        mapString  = values["mapString"]! as! String
        mediaURL   = values["mediaURL"]! as! String
        latitude   = values["latitude"]! as! Double
        longitude  = values["longitude"]! as! Double
        occurances = 1
    }
 
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // public interface
    //
    
    func fullName() -> String {
        return self.firstName + " " + self.lastName
    }
}
