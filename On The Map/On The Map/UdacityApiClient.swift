//
//  UdacityApiClient.swift
//  On The Map
//
//  Created by Johan Smet on 21/06/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import Foundation

class UdacityApiClient : WebApiClient {
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    var sessionId : String = ""
    var userId : String = ""
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // constants
    //
    
    static let BASE_URL : String = "https://www.udacity.com/"

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
        
        // make the request
        startTaskPOST(UdacityApiClient.BASE_URL, method: "api/session", parameters: [:], jsonBody: postBody) { result, error in
            
            if let basicError = error as? NSError {
                completionHandler(error: UdacityApiClient.formatBasicError(basicError))
            } else if let httpError = error as? NSHTTPURLResponse {
                completionHandler(error: UdacityApiClient.formatHttpError(httpError))
            } else {
                let postResult = result as! NSDictionary
                
                // session-id
                if let session = postResult.valueForKey("session") as? [String : AnyObject] {
                    self.sessionId = session["id"] as! String
                } else {
                    completionHandler(error: "session-id missing from response")
                    return
                }
                
                // user-id
                if let account = postResult.valueForKey("account") as? [String : AnyObject] {
                    self.userId = account["key"] as! String
                } else {
                    completionHandler(error: "user-key missing from response")
                    return
                }
                
                completionHandler(error: nil)
            }
        }
    }
    
    func getUserData(userId : String, completionHandler: (user : User?, error: String?) -> Void) {
        
        // make the request
        startTaskGET(UdacityApiClient.BASE_URL, method: "api/users/" + userId, parameters: [:]) { result, error in
            
            if let basicError = error as? NSError {
                completionHandler(user: nil, error: UdacityApiClient.formatBasicError(basicError))
            } else if let httpError = error as? NSHTTPURLResponse {
                completionHandler(user: nil, error: UdacityApiClient.formatHttpError(httpError))
            } else {
                if let userDict = (result as! NSDictionary).valueForKey("user") as? [String : AnyObject] {
                    
                    var user : User? = nil
                    
                    // parse the result
                    if let firstName = userDict["first_name"] as? String,
                       let lastName = userDict["last_name"] as? String {
                        user = User(userId: userId, firstName: firstName, lastName: lastName)
                    } else {
                        completionHandler(user: nil, error: "Required field missing from response")
                        return
                    }
                    
                    if let linkedIn = userDict["linkedin_url"] as? String {
                        user?.linkedInUrl = linkedIn
                    }
                    
                    completionHandler(user: user, error: nil)
                } else {
                    completionHandler(user: nil, error: "Required field missing from response")
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