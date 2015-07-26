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
    
    var studentLocations    : [StudentInformation] = []
    var studentIndices      : [String : Int] = [:]
    
    var user : User?
    var userLocation : StudentInformation?
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // student manipulation
    //
    
    func clearStudents() {
        studentLocations.removeAll(keepCapacity: true)
        studentIndices.removeAll(keepCapacity: true)
    }
    
    func addStudents(studentList : [AnyObject]) {
        for student in studentList {
            addStudent(student as! [String : AnyObject])
        }
    }
    
    func upsertPostedStudent(student : StudentInformation) {

        if let existingIndex = studentIndices[student.uniqueKey] {
            // update information of an existing student and move it to the start of the array
            var updStudent = studentLocations[existingIndex]
            studentLocations.removeAtIndex(existingIndex)
            
            updStudent.mediaURL = student.mediaURL
            updStudent.mapString = student.mapString
            updStudent.latitude = student.latitude
            updStudent.longitude = student.longitude
            studentLocations.insert(updStudent, atIndex: 0)
        } else {
            // new pin - add it to the beginning of the array
            studentLocations.insert(student, atIndex: 0)
        }
        
        // rebuild the student-indices dictionary
        studentIndices.removeAll(keepCapacity: true)
        
        for (key, value) in enumerate(studentLocations) {
            studentIndices[value.uniqueKey] = key
        }
    }
    
    func studentByIndex(index : Int) -> StudentInformation? {
       
        if index < 0 || index >= studentLocations.count {
            return nil
        }
        
        return studentLocations[index]
    }
    
    private func addStudent(student : [String : AnyObject]) {
        var studentInfo = StudentInformation(values: student)
       
        if !filterBadStudents(studentInfo) {
            return
        }
        
        if let existingIndex = studentIndices[studentInfo.uniqueKey] {
            // duplicate entry for a student - don't overwrite data with older information
            studentLocations[existingIndex].occurances++
        } else {
            let index = studentLocations.count;
            studentLocations.append(studentInfo)
            studentIndices[studentInfo.uniqueKey] = index;
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