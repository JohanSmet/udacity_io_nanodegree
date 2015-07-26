//
//  DataLoader.swift
//  On The Map
//
//  Created by Johan Smet on 24/06/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import Foundation

class DataLoader {
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // constants
    //
    
    private static let MAX_STUDENT_PASS_COUNT = 3
    private static let STUDENT_COUNT = 100
    private static let EXTRA_STUDENT_COUNT = 30
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    private static var skipCount : Int = 0
    private static var loadingData : Bool = false
    private static var disableExtra : Bool = false
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // public interface
    //
    
    static func loadData(completionHandlerUI : (error : String?) -> Void) {
       
        // TASK-1: load more information about the current user
        DataLoader.loadStudentData() { error in
            if let error = error {
                return DataLoader.runCompletionHandler(error, completionHandlerUI: completionHandlerUI)
            }
            
            // TASK-2 : check if the current user has entered a location
            DataLoader.checkLocationCurrentUser() { error in
                
                if let error = error {
                    return DataLoader.runCompletionHandler(error, completionHandlerUI: completionHandlerUI)
                }
                
                // TASK-3: load student locations
                DataLoader.loadStudentLocations() { error in
                    
                    // END OF TASKS
                    DataLoader.runCompletionHandler(error, completionHandlerUI: completionHandlerUI)
                }
            }
        }
    }
    
    static func loadExtraData(completionHandlerUI : (error : String?) -> Void) {
        
        if DataLoader.loadingData || DataLoader.disableExtra {
            return
        }
        
        DataLoader.loadingData = true
      
        // load the data from the udacity parse service
        UdacityParseClient.instance().listStudentLocations(DataLoader.EXTRA_STUDENT_COUNT, skipCount : DataLoader.skipCount) { studentLocations, parseError in
            
            var error = parseError
            
            // process the data
            if let studentList = studentLocations {
                
                if studentList.count > 0 {
                    DataLoader.skipCount += studentList.count
                    DataContext.instance().addStudents(studentList)
                } else {
                    DataLoader.disableExtra = true
                }
            }
            
            // signal completion
            DataLoader.runCompletionHandler(error, completionHandlerUI: completionHandlerUI)
            DataLoader.loadingData = false
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // utility functions
    //
    
    static func loadStudentData(completionHandler : (error : String?) -> Void) {
        
        UdacityApiClient.instance().getUserData(UdacityApiClient.instance().userId) { user, error in
            DataContext.instance().user = user
            completionHandler(error: error)
        }
        
    }
    
    static func loadStudentLocations(completionHandler : (error : String?) -> Void) {
        
        // remove all current data
        DataContext.instance().clearStudents()
        
        // reset tracking variables
        DataLoader.disableExtra = false
        DataLoader.skipCount    = 0
        
        // start loading new data
        r_loadStudentLocations(0, completionHandler: completionHandler)
    }
    
    static func r_loadStudentLocations(passCount : Int, completionHandler : (error : String?) -> Void) {
        
        DataLoader.loadingData  = true
        
        // load the data from the udacity parse service
        UdacityParseClient.instance().listStudentLocations(100, skipCount : DataLoader.skipCount) { studentLocations, parseError in
            
            var error = parseError
            
            // process the data
            if let studentList = studentLocations {
                DataLoader.skipCount += studentList.count
                DataContext.instance().addStudents(studentList)
            }
            
            // keep loading data until we have enough students or reach we the maximum pass count
            DataLoader.loadingData = false
            
            if DataContext.instance().studentLocations.count < DataLoader.STUDENT_COUNT && passCount < DataLoader.MAX_STUDENT_PASS_COUNT {
                DataLoader.r_loadStudentLocations(passCount + 1, completionHandler: completionHandler)
            }
            
            // signal completion (even if we're loading more data)
            completionHandler(error: error)
        }
    }
    
    static func checkLocationCurrentUser(completionHandler : (error : String?) -> Void) {
        
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