//
//  InformationPostingController.swift
//  On The Map
//
//  Created by Johan Smet on 17/06/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import UIKit
import Foundation
import MapKit

class InformationPostingController: UIViewController {
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // outlets
    //

    @IBOutlet weak var containerLocation: UIView!
    @IBOutlet weak var containerLink: UIView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var locationText: UITextView!
    @IBOutlet weak var linkText: UITextView!
    
    @IBOutlet weak var buttonSubmit: UIButton!
    @IBOutlet weak var buttonFindOnMap: UIButton!
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    private var locationCoordinate : CLLocationCoordinate2D?
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController overrides
    //
    
    override func viewDidLoad() {
        
        // UI tweaks
        buttonSubmit.layer.cornerRadius = 5
        buttonFindOnMap.layer.cornerRadius = 5
        
        // show the information previously entered by the user
        if let userLocation = DataContext.instance().userLocation {
            locationText.text = userLocation.mapString
            linkText.text = userLocation.mediaURL
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        // make sure to show the correct view
        containerLocation.hidden = false
        containerLink.hidden = true
        
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // actions
    //
    
    @IBAction func cancelPostFromLocation(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelPostFromLink(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func findOnMap(sender: AnyObject) {
        
        // did the user enter a location ?
        if locationText.text!.isEmpty {
            alert("You must enter a location before you can continue!", title: "Attention")
            return
        }
        
        // geocode
        geocodeLocation(locationText.text!) { error in
            
            if let error = error {
                self.alert(error.localizedDescription)
            } else {
                // show the entered location on the map
                let annotation = MKPointAnnotation()
                annotation.coordinate = self.locationCoordinate!
                self.mapView.addAnnotation(annotation)
                
                // center on te location
                self.mapView.setRegion(MKCoordinateRegion(center: self.locationCoordinate!, span: MKCoordinateSpanMake(0.01, 0.01)), animated: true)
                
                // switch to the next view
                self.containerLocation.hidden = true
                self.containerLink.hidden = false
            }
        }
    }

    @IBAction func submitLocation(sender: AnyObject) {
       
        // did the user enter a link
        if linkText.text!.isEmpty {
            alert("You must enter a link before you can continue!", title: "Attention")
            return
        }
        
        // build a studentinformation object
        var studentInformation : StudentInformation
        
        if let userLocation = DataContext.instance().userLocation {
            studentInformation = userLocation
        } else {
            let user = DataContext.instance().user!
            studentInformation = StudentInformation(uniqueKey: user.userId, firstName: user.firstName, lastName: user.lastName)
            DataContext.instance().userLocation = studentInformation
        }
        
       studentInformation.mapString = locationText.text
       studentInformation.mediaURL  = linkText.text
       studentInformation.latitude  = locationCoordinate!.latitude
       studentInformation.longitude = locationCoordinate!.longitude
       
        // submit the information to udacity
        UdacityParseClient.instance().postStudentLocation(studentInformation) { objectId, error in
            if let error = error {
                self.alert(error, title: "Attention")
                return
            }
           
            if let objectId = objectId {
                DataContext.instance().userLocation!.objectId = objectId
            }
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // helper functions
    //
    
    private func geocodeLocation(location : String, completionHandler: (error : NSError?) -> Void) {
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(location, completionHandler: { (placemarks : [AnyObject]!, error : NSError?) in
            if let error = error {
                completionHandler(error: error)
            } else {
                let placemark = placemarks[0] as! CLPlacemark
                self.locationCoordinate = placemark.location.coordinate
                completionHandler(error: nil)
            }
        })
    }
    
    private func alert(message : String, title : String = "Alert") {
        dispatch_async(dispatch_get_main_queue(), {
            var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }
    
    
}

