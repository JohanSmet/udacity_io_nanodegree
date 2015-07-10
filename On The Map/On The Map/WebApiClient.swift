//
//  WebApiClient.swift
//  On The Map
//
//  Created by Johan Smet on 19/06/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import Foundation

class WebApiClient {
    
    // shared session
    var urlSession : NSURLSession
    var dataOffset : Int = 0
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // initializers
    //
    
    init() {
        self.urlSession = NSURLSession.sharedSession()
    }
    
    init(dataOffset : Int) {
        self.urlSession = NSURLSession.sharedSession()
        self.dataOffset = dataOffset
    }
    
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // wrappers for GET-request
    //
    
    func startTaskGET(serverURL: String, method: String, parameters : [String : AnyObject], completionHandler: (result: AnyObject!, error: AnyObject?) -> Void) -> NSURLSessionDataTask? {
        return startTaskHTTP("GET", serverURL: serverURL, apiMethod: method,
                             parameters: parameters, extraHeaders: [:], jsonBody: nil,
                             completionHandler: completionHandler)
    }
    
    func startTaskGET(serverURL: String, method: String, parameters : [String : AnyObject], extraHeaders : [String : String],
                      completionHandler: (result: AnyObject!, error: AnyObject?) -> Void) -> NSURLSessionDataTask? {
        return startTaskHTTP("GET", serverURL: serverURL, apiMethod: method,
                             parameters: parameters, extraHeaders: extraHeaders, jsonBody: nil,
                             completionHandler: completionHandler)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // wrapper for POST-request
    //
    
    func startTaskPOST(serverURL: String, method: String, parameters : [String : AnyObject], jsonBody: AnyObject,
                       completionHandler: (result: AnyObject!, error: AnyObject?) -> Void) -> NSURLSessionDataTask? {
        return startTaskHTTP("POST", serverURL: serverURL, apiMethod: method,
                             parameters: parameters, extraHeaders: [:], jsonBody: jsonBody,
                             completionHandler: completionHandler)
    }

    func startTaskPOST(serverURL: String, method: String, parameters : [String : AnyObject], extraHeaders: [String : String], jsonBody: AnyObject,
                       completionHandler: (result: AnyObject!, error: AnyObject?) -> Void) -> NSURLSessionDataTask? {
        return startTaskHTTP("POST", serverURL: serverURL, apiMethod: method,
                             parameters: parameters, extraHeaders: extraHeaders, jsonBody: jsonBody,
                             completionHandler: completionHandler)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // wrapper for DELETE-request
    //
    
    func startTaskDELETE(serverURL : String, apiMethod : String, parameters : [String : AnyObject],
                         completionHandler: (result: AnyObject!, error: AnyObject?) -> Void) -> NSURLSessionDataTask? {
        return startTaskHTTP("DELETE", serverURL: serverURL, apiMethod: apiMethod,
                             parameters: parameters, extraHeaders: [:], jsonBody: nil,
                             completionHandler: completionHandler)
    }
    
    func startTaskDELETE(serverURL : String, apiMethod : String, parameters : [String : AnyObject], extraHeaders: [String : String],
                         completionHandler: (result: AnyObject!, error: AnyObject?) -> Void) -> NSURLSessionDataTask? {
        return startTaskHTTP("DELETE", serverURL: serverURL, apiMethod: apiMethod,
                             parameters: parameters, extraHeaders: extraHeaders, jsonBody: nil,
                             completionHandler: completionHandler)
    }
   
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // generic HTTP-request
    //
    
    func startTaskHTTP(httpMethod : String, serverURL: String, apiMethod: String, parameters : [String : AnyObject], extraHeaders: [String : String], jsonBody: AnyObject?,
        completionHandler: (result: AnyObject!, error: AnyObject?) -> Void) -> NSURLSessionDataTask? {
            
            // build the url
            let url = NSURL(string: serverURL + apiMethod + WebApiClient.formatURLParameters(parameters))!
            
            // configure the request
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = httpMethod
           
            // headers
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            for (hKey, hValue) in extraHeaders {
                request.addValue(hValue, forHTTPHeaderField: hKey)
            }
            
            // optional body
            if let jsonBody: AnyObject = jsonBody {
                var jsonError : NSError? = nil
                request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: NSJSONWritingOptions.PrettyPrinted, error: &jsonError)
            
                if let error = jsonError {
                    completionHandler(result: nil, error: String.localizedStringWithFormat(NSLocalizedString("cliInternalJsonError", comment:"Internal error : invalid jsonBody (error: %s)"), error))
                    return nil                              // exit !!!
                }
                
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            
            // submit the request
            let task = urlSession.dataTaskWithRequest(request) { data, response, urlError in
                
                // check for basic connectivity errors
                if let error = urlError {
                    completionHandler(result: nil, error: error)
                    return
                }
                
                // check for HTTP errors
                if let httpResponse = response as? NSHTTPURLResponse {
                    if WebApiClient.httpStatusIsError(httpResponse.statusCode) {
                        completionHandler(result: nil, error: httpResponse)
                        return
                    }
                }
                
                // parse the JSON
                var parseError : NSError? = nil
                let parseResult: AnyObject! = WebApiClient.parseJSON(data.subdataWithRange(NSMakeRange(self.dataOffset, data.length - self.dataOffset)), errorPtr: &parseError)
                completionHandler(result: parseResult, error: parseError)
            }
            
            // submit the request to the server
            task.resume()
            
            return task
    }
    
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // helper functions
    //
    
    private class func formatURLParameters(parameters : [String : AnyObject]) -> String {
     
        var result = ""
        var delim  = "?"
        
        for (key, value) in parameters {
            
            // be sure to convert to a string
            let stringValue = "\(value)"
            
            // escape the value
            let escValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            // append to the result
            result += delim + key + "=" + "\(escValue!)"
            delim = "&"
        }
        
        return result;
    }
    
    private class func parseJSON(data : NSData, errorPtr : NSErrorPointer) -> AnyObject! {
        let parsedResult : AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: errorPtr)
        return parsedResult
    }
    
    private class func httpStatusIsError(statusCode : Int) -> Bool {
        
        return statusCode >= 400
        
    }
    
}