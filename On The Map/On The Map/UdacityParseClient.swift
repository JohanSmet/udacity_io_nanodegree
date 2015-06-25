//
//  UdacityParseClient.swift
//  On The Map
//
//  Created by Johan Smet on 23/06/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import Foundation

class UdacityParseClient : WebApiClient {
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // constants
    //
    
    static let PARSE_APPLICATION_ID : String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    static let REST_API_KEY : String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    
    static let BASE_URL : String = "https://api.parse.com/1/classes/"
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // initializers
    //
    
    override init() {
        super.init(dataOffset: 0)
    }

    ///////////////////////////////////////////////////////////////////////////////////
    //
    // request interface
    //
    
    func listStudentLocations(completionHandler : (studentLocations : [AnyObject]?, error : String?) -> Void) {
    
        let extraHeaders : [String : String] = [
            "X-Parse-Application-Id" : UdacityParseClient.PARSE_APPLICATION_ID,
            "X-Parse-REST-API-Key"  : UdacityParseClient.REST_API_KEY
        ]
        
        let parameters : [String : String] = [
            "limit" : "100"
        ]
        
        // make request
        startTaskGET(UdacityParseClient.BASE_URL, method: "StudentLocation", parameters: parameters, extraHeaders: extraHeaders) { result, error in
            if let basicError = error as? NSError {
                completionHandler(studentLocations: nil, error: UdacityParseClient.formatBasicError(basicError))
            } else if let httpError = error as? NSHTTPURLResponse {
                completionHandler(studentLocations: nil, error: UdacityParseClient.formatHttpError(httpError))
            } else {
                let postResult = result as! NSDictionary;
                let studentLocations = postResult.valueForKey("results") as! [AnyObject]?
                completionHandler(studentLocations: studentLocations, error: nil)
            }
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // helper functions
    //
    
    private class func formatBasicError(error : NSError) -> String {
        return error.localizedDescription
    }
    
    private class func formatHttpError(response : NSHTTPURLResponse) -> String {
        
        if (response.statusCode == 403) {
            return "Invalid username or password"
        } else {
            return "HTTP-error \(response.statusCode)"
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////
    //
    // singleton
    //
    
    class func instance() -> UdacityParseClient {
        
        struct Singleton {
            static var instance = UdacityParseClient()
        }
        
        return Singleton.instance
    }
    

}