//
//  Student.swift
//  Virtual Tourist
//
//  Created by Johan Smet on 18/08/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//
//  Please note this functionality was only added to satisfy the condition "The object model contains additional entities."
//  of the grading rubric to make the app exceed the specification. I didn't want to add too much functionality that is not
//  in the specification, so I only made a simple two-hour implementation as a proof of concept.
//  The 100 latest records of the Udacity Parse API from the "On The Map"-application are retrieved and stored in CoreData.
//  When a pin is tapped, the app displays how many students are in the general vincinity of the pin.

import Foundation
import CoreData

@objc(Student)

class Student : NSManagedObject {
    
    @NSManaged var uniqueKey : String
    @NSManaged var latitude  : NSNumber
    @NSManaged var longitude : NSNumber
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // initialisers
    //
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(values : [String : AnyObject], context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("Student", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // properties
        self.uniqueKey  = values["uniqueKey"]! as! String
        self.latitude   = NSNumber(double: values["latitude"]! as! Double)
        self.longitude  = NSNumber(double: values["longitude"]! as! Double)
    }
    
    func update(values : [String : AnyObject]) {
        self.latitude   = NSNumber(double: values["latitude"]! as! Double)
        self.longitude  = NSNumber(double: values["longitude"]! as! Double)
    }
}