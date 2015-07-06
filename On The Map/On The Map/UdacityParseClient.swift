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
    
    func listStudentLocations(fetchCount : Int, skipCount : Int, completionHandler : (studentLocations : [AnyObject]?, error : String?) -> Void) {
    
        let extraHeaders : [String : String] = [
            "X-Parse-Application-Id" : UdacityParseClient.PARSE_APPLICATION_ID,
            "X-Parse-REST-API-Key"  : UdacityParseClient.REST_API_KEY
        ]
        
        let parameters : [String : AnyObject] = [
            "limit" : fetchCount,
            "skip"  : skipCount,
            "order" : "-updatedAt"
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
    
    func postStudentLocation(studentLocation : StudentInformation, completionHandler : (objectId : String?, error : String?) -> Void) {
        
        let extraHeaders : [String : String] = [
            "X-Parse-Application-Id" : UdacityParseClient.PARSE_APPLICATION_ID,
            "X-Parse-REST-API-Key"  : UdacityParseClient.REST_API_KEY
        ]
        
        let postBody : [ String : AnyObject] = [
            "uniqueKey" : studentLocation.uniqueKey,
            "firstName" : studentLocation.firstName,
            "lastName"  : studentLocation.lastName,
            "mapString" : studentLocation.mapString,
            "mediaURL"  : studentLocation.mediaURL,
            "latitude"  : studentLocation.latitude,
            "longitude" : studentLocation.longitude
        ]
        
        // this function can be used to create an new (no objectId present) or update an existing (objectId present) entity
        var apiMethod  = "StudentLocation"
        var httpMethod = "POST"
        
        if !studentLocation.objectId.isEmpty {
            apiMethod += "/" + studentLocation.objectId
            httpMethod = "PUT"
        }
        
        // make request
        startTaskHTTP(httpMethod, serverURL: UdacityParseClient.BASE_URL, apiMethod: apiMethod, parameters: [:], extraHeaders: extraHeaders, jsonBody: postBody) { result, error in
            if let basicError = error as? NSError {
                completionHandler(objectId: nil, error: UdacityParseClient.formatBasicError(basicError))
            } else if let httpError = error as? NSHTTPURLResponse {
                completionHandler(objectId: nil, error: UdacityParseClient.formatHttpError(httpError))
            } else {
                let postResult = result as! NSDictionary;
                completionHandler(objectId: postResult["objectId"] as? String, error: nil)
            }
        }
    }
    
    func queryStudentLocation(studentId : String, completionHandler : (studentLocation : AnyObject?, error : String?) -> Void)  {
        
        let extraHeaders : [String : String] = [
            "X-Parse-Application-Id" : UdacityParseClient.PARSE_APPLICATION_ID,
            "X-Parse-REST-API-Key"   : UdacityParseClient.REST_API_KEY
        ]
        
        let parameters : [String : String] = [
            "where" : "{\"uniqueKey\":\"\(studentId)\"}"
        ]
        
        // make request
        startTaskGET(UdacityParseClient.BASE_URL, method: "StudentLocation", parameters: parameters, extraHeaders: extraHeaders) { result, error in
            if let basicError = error as? NSError {
                completionHandler(studentLocation: nil, error: UdacityParseClient.formatBasicError(basicError))
            } else if let httpError = error as? NSHTTPURLResponse {
                completionHandler(studentLocation: nil, error: UdacityParseClient.formatHttpError(httpError))
            } else {
                let postResult = result as! NSDictionary;
                let studentLocations = postResult.valueForKey("results") as! [AnyObject]?
                
                if studentLocations?.count > 0 {
                   completionHandler(studentLocation: studentLocations![0], error: nil)
                } else {
                   completionHandler(studentLocation: nil, error: nil)
                }
                
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