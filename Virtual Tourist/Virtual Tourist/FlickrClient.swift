//
//  FlickrApiClient.swift
//  Virtual Tourist
//
//  Created by Johan Smet on 09/08/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import Foundation

class FlickrClient : WebApiClient {
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // constants
    //
    
    static let API_KEY : String = "07a2c17566b035226e91de9a4ff0980d"
    static let BASE_URL : String = "https://api.flickr.com/services/rest/"
    
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
    
    func searchPhotoByGeo(latitude : Double, longitude : Double, maxResults : Int, completionHandler : (photos : [AnyObject]?, error : String?) -> Void) {
        
        let parameters : [String : AnyObject] = [
            "method"    : "flickr.photos.search",
            "api_key"   : FlickrClient.API_KEY,
            "format"    : "json",
            "nojsoncallback" : "1",
            "lat"       : "\(latitude)",
            "lon"       : "\(longitude)",
            "per_page"  : "\(maxResults)"
        ]
        
        // make request
        startTaskGET(FlickrClient.BASE_URL, method: "", parameters: parameters) { result, error in
            if let basicError = error as? NSError {
                completionHandler(photos: nil, error: FlickrClient.formatBasicError(basicError))
            } else if let httpError = error as? NSHTTPURLResponse {
                completionHandler(photos : nil, error: FlickrClient.formatHttpError(httpError))
            } else {
                let httpResult = result as! NSDictionary;
                
                let photos = httpResult.valueForKey("photos") as! NSDictionary
                let photo  = photos.valueForKey("photo") as? [AnyObject]
                
                completionHandler(photos: photo, error: nil)
            }
        }
    }
    
    func urlForPhoto (flickrPhoto : [String : AnyObject], size : String) -> String {
        let farm    = flickrPhoto["farm"] as! Int
        let server  = flickrPhoto["server"] as! String
        let id      = flickrPhoto["id"] as! String
        let secret  = flickrPhoto["secret"] as! String
        
        return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_\(size).jpg"
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
            return NSLocalizedString("cliInvalidCredentials", comment:"Invalid username or password")
        } else {
            return "HTTP-error \(response.statusCode)"
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // singleton
    //
    
    class func instance() -> FlickrClient {
        
        struct Singleton {
            static var instance = FlickrClient()
        }
        
        return Singleton.instance
    }
}


func flickrClient() -> FlickrClient {
    return FlickrClient.instance()
}