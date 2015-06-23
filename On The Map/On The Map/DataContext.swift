//
//  DataContext.swift
//  On The Map
//
//  Created by Johan Smet on 23/06/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import Foundation

class DataContext {

    ///////////////////////////////////////////////////////////////////////////////////
    //
    // properties
    //
    
    var studentLocations : [StudentInformation] = []
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // student manipulation
    //
    
    func addStudents(studentList : [[String : String]]) {
        for student in studentList {
            addStudent(student)
        }
    }
    
    func addStudent(student : [String : String]) {
        studentLocations.append(StudentInformation(values: student))
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // singleton
    //
    
    class func instance() -> DataContext {
        
        struct Singleton {
            static var instance = DataContext()
        }
        
        return Singleton.instance
    }
    
    
    
}