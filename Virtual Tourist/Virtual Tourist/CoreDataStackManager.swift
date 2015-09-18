//
//  CoreDataStackManager.swift
//  Virtual Tourist
//
//  Created by Johan Smet on 06/08/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import Foundation
import CoreData

private let SQLITE_FILE_NAME = "VirtualTourist.sqlite"
private let MODEL_NAME       = "VirtualTourist"

class CoreDataStackManager {
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        
        // create the managed object model
        let modelURL = NSBundle.mainBundle().URLForResource(MODEL_NAME, withExtension: "momd")!
        let model    = NSManagedObjectModel(contentsOfURL: modelURL)!
        
        // create the coordinator with the model
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        // create the persistent store
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let storeUrl = urls[urls.count-1].URLByAppendingPathComponent(SQLITE_FILE_NAME)
        
        if coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeUrl, options: nil, error: &self.lastError) == nil {
            NSLog("Unresolved error \(self.lastError), \(self.lastError!.userInfo)")
            return nil                                    // exit !!!
        }
        
        // finally, create the managed object context
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        
        return managedObjectContext
    }()
    
    func saveContext () -> Bool {
        
        if managedObjectContext == nil {
            return false
        }
        
        if !managedObjectContext!.hasChanges {
            return true
        }
        
        if !managedObjectContext!.save(&self.lastError) {
            NSLog("Unresolved error \(self.lastError), \(self.lastError!.userInfo)")
            return false
        }
        
        return true
    }
    
    var lastError : NSError? = nil
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // singleton
    //
    
    static let sharedInstance = CoreDataStackManager()
}

// shorthand way to get the CoreDataStackManager shared instance
func coreDataStackManager() -> CoreDataStackManager {
    return CoreDataStackManager.sharedInstance
}
