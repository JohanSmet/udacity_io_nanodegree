//
//  PhotoDownloadService.swift
//  Virtual Tourist
//
//  Created by Johan Smet on 09/08/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import Foundation

class PhotoDownloadService {
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // constants
    //
    
    static let NUM_PHOTOS_PER_LOCATION = 30
    static let MAX_CONCURRENT_FLICKR_DOWNLOADS = 4
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    static private let flickrQueue : dispatch_queue_t       = dispatch_queue_create("be.justcode.flickr_download", DISPATCH_QUEUE_CONCURRENT)
    static private let flickrLimit : dispatch_semaphore_t   = dispatch_semaphore_create(MAX_CONCURRENT_FLICKR_DOWNLOADS)
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // public interface
    //
    
    static func downloadPhotosForLocation(location : Pin, completionHandlerUI : (error : String?) -> Void) {
      
        flickrClient().searchPhotoByGeo(location.latitude as Double, longitude: location.longitude as Double, maxResults: NUM_PHOTOS_PER_LOCATION) { flickrPhotos, error in
            
            if let photos = flickrPhotos {
                for flickrPhoto in photos {
                    PhotoDownloadService.processFlickrPhoto(location, flickrPhoto: flickrPhoto as! [String : AnyObject])
                }
            }
            
            PhotoDownloadService.runCompletionHandler(error, completionHandlerUI: completionHandlerUI)
        }
    }
    
    static private func processFlickrPhoto(location : Pin, flickrPhoto : [String : AnyObject]) {
       
        // create the photo-object (XXX for now only call coredata on the main thread :-( )
        dispatch_async(dispatch_get_main_queue()) {
            let url = flickrClient().urlForPhoto(flickrPhoto, size: "q")
            let photo = Photo(flickrUrl: url, location: location, context: coreDataStackManager().managedObjectContext!)
            coreDataStackManager().saveContext()
            
            // download the image itself from flickr
            dispatch_async(PhotoDownloadService.flickrQueue) {
                PhotoDownloadService.downloadFlickrPhoto(photo)
            }
        }
    }
    
    static private func downloadFlickrPhoto(photo : Photo) {
        
        // do not make to many concurrent connections to flickr
        dispatch_semaphore_wait(PhotoDownloadService.flickrLimit, DISPATCH_TIME_FOREVER)
        
        // download the data
        let photoData = NSData(contentsOfURL: NSURL(string: photo.flickrUrl)!)
        
        // save photo to file system
        let documentsDirectory: AnyObject = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]
        let path = documentsDirectory.stringByAppendingPathComponent(NSUUID().UUIDString + ".jpg")
        photoData?.writeToFile(path, atomically: false)
        
        // update the photo record in coredata
        dispatch_async(dispatch_get_main_queue()) {
            photo.localUrl = path
            coreDataStackManager().saveContext()
        }
        
        dispatch_semaphore_signal(PhotoDownloadService.flickrLimit)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // utility functions
    //
    
    static func runCompletionHandler(error : String?, completionHandlerUI : (error : String?) -> Void) {
        dispatch_async(dispatch_get_main_queue(), {
            completionHandlerUI(error: error)
        })
    }
    
}