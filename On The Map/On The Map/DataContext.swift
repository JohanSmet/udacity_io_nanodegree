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
    
    var studentLocationsMap : [String : StudentInformation] = [:]
    var studentLocations    : [StudentInformation] = []
    
    var user : User?
    var userLocation : StudentInformation?
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // student manipulation
    //
    
    func clearStudents() {
        studentLocationsMap.removeAll(keepCapacity: true)
        studentLocations.removeAll(keepCapacity: true)
    }
    
    func addStudents(studentList : [AnyObject]) {
        for student in studentList {
            addStudent(student as! [String : AnyObject])
        }
        
        // refresh the array that is used by the rest of the app
        studentLocations = studentLocationsMap.values.array
    }
    
    func studentByIndex(index : Int) -> StudentInformation? {
       
        if index < 0 || index >= studentLocationsMap.count {
            return nil
        }
        
        return studentLocations[index]
    }
    
    private func addStudent(student : [String : AnyObject]) {
        var studentInfo = StudentInformation(values: student)
       
        if filterBadStudents(studentInfo) {
            var entryCount = 0
            
            if let entry = studentLocationsMap[studentInfo.uniqueKey] {
                entryCount = entry.occurances
            }
           
            studentInfo.occurances += entryCount
            studentLocationsMap[studentInfo.uniqueKey] = studentInfo
        }
    }
    
    private func filterBadStudents(student : StudentInformation) -> Bool {
        
        // check for decent unique key
        if student.uniqueKey == "nil" ||        // not filled in
           student.uniqueKey == "1234" ||       // from the API documentation
           count(student.uniqueKey) > 16 {      // could be mistaken but probably using session-id as key
            return false
        }
        
        return true
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