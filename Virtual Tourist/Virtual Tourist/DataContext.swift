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
    // photo management
    //
    
    func deletePhotos(photos : [Photo]) {
        for photo in photos {
            coreDataStackManager().managedObjectContext!.deleteObject(photo)
        }
        
        coreDataStackManager().saveContext()
    }
    
    func deletePhotosOfPin(location : Pin) {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.predicate       = NSPredicate(format: "location == %@", location)
        
        deletePhotos(coreDataStackManager().managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as! [Photo])
    }
    
    func allPhotosOfPinComplete(location : Pin) ->  Bool {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.predicate       = NSPredicate(format: "location == %@ && localUrl = nil", location)
        
        let incomplete = coreDataStackManager().managedObjectContext!.countForFetchRequest(fetchRequest, error: nil)
        return incomplete == 0
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