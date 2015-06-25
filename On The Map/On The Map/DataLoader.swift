//
//  DataLoader.swift
//  On The Map
//
//  Created by Johan Smet on 24/06/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import Foundation

class DataLoader {
    
    static func loadStudentLocations(completionHandlerUI : (error : String?) -> Void) {
       
        // load the data from the udacity parse service
        UdacityParseClient.instance().listStudentLocations() { studentLocations, parseError in
            
            var error = parseError
            
            // process the data
            if let studentList = studentLocations {
                DataContext.instance().addStudents(studentList)
            }
            
            // signal completion (in the main thread)
            dispatch_async(dispatch_get_main_queue(), {
                completionHandlerUI(error: error)
            })
        }
    }
    
    
}