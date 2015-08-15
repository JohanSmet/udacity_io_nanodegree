//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Johan Smet on 09/08/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import Foundation
import CoreData

@objc(Photo)

class Photo : NSManagedObject {
    
    @NSManaged var flickrUrl : String
    @NSManaged var localUrl  : String?
    @NSManaged var location  : Pin
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // initialisers
    //
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(flickrUrl : String, location : Pin, context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // properties
        self.flickrUrl = flickrUrl
        self.location  = location
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // NSManagedObject overrides
    //
    
    override func prepareForDeletion() {
        // also delete the image file when a photo is removed from core data
        if let localUrl = self.localUrl {
            let documentsDirectory: AnyObject = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]
            let path = documentsDirectory.stringByAppendingPathComponent(localUrl)
            NSFileManager.defaultManager().removeItemAtPath(path, error: nil)
        }
    }
}
