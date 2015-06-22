//
//  UdacityApiClient.swift
//  On The Map
//
//  Created by Johan Smet on 21/06/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import Foundation

class UdacityApiClient : WebApiClient {
    
    var sessionId : String = ""

    ///////////////////////////////////////////////////////////////////////////////////
    //
    // initializers
    //
    
    override init() {
        super.init(dataOffset: 5)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // request interface
    //
    
    func createSession(username : String, password : String, completionHandler: (error: String?) -> Void) {
        
        // create the body of the request
        let postBody : [ String : AnyObject] = [
            "udacity" : [
                "username" : username,
                "password" : password
            ]
        ]
        
        startTaskPOST("https://www.udacity.com/", method: "api/session", parameters: [:], jsonBody: postBody) { result, error in
            
            if let basicError = error as? NSError {
                completionHandler(error: UdacityApiClient.formatBasicError(basicError))
            } else if let httpError = error as? NSHTTPURLResponse {
                completionHandler(error: UdacityApiClient.formatHttpError(httpError))
            } else {
                let postResult = result as! NSDictionary
                
                if let session = postResult.valueForKey("session") as? [String : AnyObject] {
                    self.sessionId = session["id"] as! String
                    completionHandler(error: nil)
                }
            }
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // helper functions
    //
    
    private class func formatBasicError(error : NSError) -> String {
        return "Unable to contact server"
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
    
    class func instance() -> UdacityApiClient {
        
        struct Singleton {
            static var instance = UdacityApiClient()
        }
        
        return Singleton.instance
    }
    
    
    
    
}