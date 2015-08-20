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
        
        // get the first page on the first request, get a random page on subsequent requests
        var page = 1
        
        if location.pages.integerValue > 0 {
            page = Int(arc4random_uniform(UInt32(location.pages.integerValue))) + 1
        }
      
        flickrClient().searchPhotoByGeo(location.latitude as Double, longitude: location.longitude as Double,
                                        maxResults: NUM_PHOTOS_PER_LOCATION, page: page) { flickrPhotos, pages, error in
            
            // store the number of pages for the location
            dispatch_sync(dispatch_get_main_queue()) {
                location.pages = pages
            }

            if let photos = flickrPhotos as? [[String : AnyObject]] {
                
                // create photos in coredata
                PhotoDownloadService.createPhotosCoreData(location, flickrPhotos: photos)
                
                // download the images
                dispatch_async(PhotoDownloadService.flickrQueue) {
                    PhotoDownloadService.downloadPhotos(location)
                }
            }
            
            PhotoDownloadService.runCompletionHandler(error, completionHandlerUI: completionHandlerUI)
        }
    }
    
    static private func createPhotosCoreData(location : Pin, flickrPhotos : [[String : AnyObject]]) {
        
        dispatch_sync(dispatch_get_main_queue()) {
            for flickrPhoto in flickrPhotos {
                let url = flickrClient().urlForPhoto(flickrPhoto, size: "q")
                let photo = Photo(flickrUrl: url, location: location, context: coreDataStackManager().managedObjectContext!)
            }
            
            coreDataStackManager().saveContext()
        }
    }
    
    static private func downloadPhotos(location : Pin) {
        
        for photo in dataContext().fetchIncompletePhotosOfPin(location) {
            // do not make to many concurrent connections to flickr
            dispatch_semaphore_wait(PhotoDownloadService.flickrLimit, DISPATCH_TIME_FOREVER)
            
            // download the image itself from flickr
            dispatch_async(PhotoDownloadService.flickrQueue) {
                PhotoDownloadService.downloadFlickrPhoto(photo)
                dispatch_semaphore_signal(PhotoDownloadService.flickrLimit)
            }
        }
        
    }
    
    static private func downloadFlickrPhoto(photo : Photo) {
        
        // download the data
        let photoData = NSData(contentsOfURL: NSURL(string: photo.flickrUrl)!)
        
        // save photo to file system
        let documentsDirectory: AnyObject = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]
        let filename = NSUUID().UUIDString + ".jpg"
        let path = documentsDirectory.stringByAppendingPathComponent(filename)
        photoData?.writeToFile(path, atomically: false)
        
        // update the photo record in coredata
        dispatch_sync(dispatch_get_main_queue()) {
            photo.localUrl = filename
            coreDataStackManager().saveContext()
        }
        
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