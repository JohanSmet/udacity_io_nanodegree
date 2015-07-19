//
//  MapTabController.swift
//  On The Map
//
//  Created by Johan Smet on 23/06/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapTabController : UIViewController,
                         AppDataTab,
                         MKMapViewDelegate {
    
    var studentAnnotations : [String : MKPointAnnotation]! = [:]
   
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // outlets
    //
    
    @IBOutlet weak var mapView: MKMapView!
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController overrides
    //
    
    override func viewDidLoad() {
        mapView.delegate = self
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // AppDataTab overrides
    //
    
    func refreshData() {
        self.refreshPins()
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // actions
    //
    
    func annotationTapGesture(sender : AnyObject) {
        if let annotionView = (sender as! UIGestureRecognizer).view as? MKAnnotationView {
            if let student = annotionView.annotation as? MKPointAnnotation {
                if isValidUrl(student.subtitle) {
                    UIApplication.sharedApplication().openURL(NSURL(string: student.subtitle)!)
                } else {
                    alertOkAsync(self, NSLocalizedString("conInvalidURL", comment: "Invalid URL!"))
                }
            }
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // MKMapViewDelegate
    //
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        if let student = annotation as? MKPointAnnotation {
            let identifier = "studentPin"
            
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) {
                dequeuedView.annotation = annotation
                return dequeuedView
            } else {
                let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset  = CGPoint(x: -5, y: -5)
                view.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIView
                return view
            }
        }
        
        return nil;
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        let tapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "annotationTapGesture:")
        view.addGestureRecognizer(tapGesture)
    }
    
    func mapView(mapView: MKMapView!, didDeselectAnnotationView view: MKAnnotationView!) {
        for recognizer in view.gestureRecognizers! {
            if recognizer is UITapGestureRecognizer  {
                view.removeGestureRecognizer(recognizer as! UIGestureRecognizer)
            }
        }
    }
    
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // helper functions
    //
    
    private func refreshPins() {
        
        // reset the list of annotations
        var prevAnnotations = studentAnnotations
        studentAnnotations.removeAll(keepCapacity: true)
        
        // rebuild the list
        for student in DataContext.instance().studentLocations {
        
            // reuse the annotation if it is already on the map
            var annotation = prevAnnotations[student.uniqueKey]
            
            if annotation == nil {
                annotation = MKPointAnnotation()
            } else {
                prevAnnotations.removeValueForKey(student.uniqueKey)
            }
            
            // update the information
            annotation!.title = student.fullName()
            annotation!.subtitle = student.mediaURL
            annotation!.coordinate = CLLocationCoordinate2D(latitude: student.latitude, longitude: student.longitude)
            
            // save the annotation
            studentAnnotations[student.uniqueKey] = annotation
            
            // add it to the map
            mapView.addAnnotation(annotation)
        }
        
        // remove annotations from the map that are no longer in the list
        for (key, value) in prevAnnotations {
            mapView.removeAnnotation(value)
        }
        
    }

}