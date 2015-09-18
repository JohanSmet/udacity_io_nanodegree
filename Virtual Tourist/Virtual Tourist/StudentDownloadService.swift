//
//  StudentDownloadService.swift
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

class StudentDownloadService {

    ////////////////////////////////////////////////////////////////////////////////
    //
    // constants
    //
    
    static let MAX_FETCH_STUDENTS = 100
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // public interface
    //
    
    static func downloadStudentLocations(completionHandlerUI : (error : String?) -> Void) {
        
        // load the data from the udacity parse service
        UdacityParseClient().listStudentLocations(StudentDownloadService.MAX_FETCH_STUDENTS, skipCount : 0) { studentLocations, parseError in
            
            // process the data
            if let studentList = studentLocations as? [[String : AnyObject]] {
                StudentDownloadService.loadStudentLocations(studentList)
            }
            
            // signal completion
            StudentDownloadService.runCompletionHandler(parseError, completionHandlerUI: completionHandlerUI)
        }
        
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // utility functions
    //
    
    static func loadStudentLocations(students : [[String : AnyObject]]) {
       
        // build a dictionary while filtering out any duplicates
        var uniqueStudents : [String : [String : AnyObject]] = [:]
        
        for student in students.reverse() {
            uniqueStudents[student["uniqueKey"]! as! String] = student
        }
        
        // retrieve and already existing students
        for student in dataContext().fetchStudentForKeys(uniqueStudents.keys.array) {
            student.update(uniqueStudents[student.uniqueKey]!)
            uniqueStudents.removeValueForKey(student.uniqueKey)
        }
        
        // create remaining students
        for (key, student) in uniqueStudents {
            let newStudent = Student(values: student, context: coreDataStackManager().managedObjectContext!)
        }
        
        // save
        coreDataStackManager().saveContext()
    }
    
    static func runCompletionHandler(error : String?, completionHandlerUI : (error : String?) -> Void) {
        dispatch_async(dispatch_get_main_queue(), {
            completionHandlerUI(error: error)
        })
    }
}