//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Johan Smet on 08/08/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import Foundation
import CoreData
import MapKit

@objc(Pin)

class Pin : NSManagedObject,
            MKAnnotation {
    
    struct Keys {
        static let ID = "id"
        static let LATITUDE = "latitude"
        static let LONGITUDE = "longitude"
    }
    
    @NSManaged var id : String
    @NSManaged var latitude : NSNumber
    @NSManaged var longitude : NSNumber
    @NSManaged var photos : [Photo]
    
    var animate : Bool = false
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // initialisers
    //
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(latitude : Double, longitude : Double, context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // properties
        self.id         = NSUUID().UUIDString
        self.latitude   = NSNumber(double: latitude)
        self.longitude  = NSNumber(double: longitude)
        self.animate    = true
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // MKAnnotation
    //
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude as Double, longitude: longitude as Double)
    }
}