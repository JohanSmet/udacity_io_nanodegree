//
//  DataContext.swift
//  Virtual Tourist
//
//  Created by Johan Smet on 08/08/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import Foundation
import CoreData

class DataContext {
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    var pins : [Pin] = []
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // pin management
    //
    
    func fetchAllPins() -> [Pin] {
        let error: NSErrorPointer = nil
        
        // create fetch request
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        // execute the fetch request
        let results = coreDataStackManager().managedObjectContext!.executeFetchRequest(fetchRequest, error: error)
        
        // check for errors
        if error != nil {
            println("Error in fectchAllPins(): \(error)")         // XXX
        }
        
        // save results
        self.pins = results as! [Pin]
        return self.pins
    }
    
    func createPin(latitude : Double, longitude : Double) -> Pin {
        // create pin
        let pin = Pin(latitude: latitude, longitude: longitude, context: coreDataStackManager().managedObjectContext!)
        pins.append(pin)
        
        // save all changes
        coreDataStackManager().saveContext()
        
        return pin
    }

    ////////////////////////////////////////////////////////////////////////////////
    //
    // singleton
    //

    class func sharedInstance() -> DataContext {
        struct Static {
            static let instance = DataContext()
        }
        
        return Static.instance
    }
}

func dataContext() -> DataContext {
    return DataContext.sharedInstance()
}