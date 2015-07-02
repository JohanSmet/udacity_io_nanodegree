//
//  DataLoader.swift
//  On The Map
//
//  Created by Johan Smet on 24/06/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import Foundation

class DataLoader {
    
    static func loadData(completionHandlerUI : (error : String?) -> Void) {
       
        // TASK-1: load more information about the current user
        DataLoader.loadStudentData() { error in
            if let error = error {
                return DataLoader.runCompletionHandler(error, completionHandlerUI: completionHandlerUI)
            }
            
            // TASK-2: load student locations
            DataLoader.loadStudentLocations() { error in
                
                if let error = error {
                    return DataLoader.runCompletionHandler(error, completionHandlerUI: completionHandlerUI)
                }
                
                // TASK-3 : check if the current user has entered a location
                DataLoader.checkLocationCurrentUser() { error in
                    
                    // END OF TASKS
                    DataLoader.runCompletionHandler(error, completionHandlerUI: completionHandlerUI)
                }
            }
        }
    }
    
    static func loadStudentData(completionHandler : (error : String?) -> Void) {
        
        UdacityApiClient.instance().getUserData(UdacityApiClient.instance().userId) { user, error in
            DataContext.instance().user = user
            completionHandler(error: error)
        }
        
    }
    
    static func loadStudentLocations(completionHandler : (error : String?) -> Void) {
        
        // load the data from the udacity parse service
        UdacityParseClient.instance().listStudentLocations() { studentLocations, parseError in
            
            var error = parseError
            
            // process the data
            if let studentList = studentLocations {
                DataContext.instance().addStudents(studentList)
            }
            
            // signal completion
            completionHandler(error: error)
        }
    }
    
    static func checkLocationCurrentUser(completionHandler : (error : String?) -> Void) {
        // XXX todo: check if the location of the user isn't already loaded in the normal list
        
        UdacityParseClient.instance().queryStudentLocation(DataContext.instance().user!.userId) { studentLocation, error in
            
            if let studentLocation = studentLocation as? [String : AnyObject] {
                DataContext.instance().userLocation = StudentInformation(values: studentLocation)
            }
            
            completionHandler(error: error)
        }
    }
    
    static func runCompletionHandler(error : String?, completionHandlerUI : (error : String?) -> Void) {
        dispatch_async(dispatch_get_main_queue(), {
            completionHandlerUI(error: error)
        })
    }
    
    
}