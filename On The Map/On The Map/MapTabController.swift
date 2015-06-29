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

class StudentAnnotation : NSObject, MKAnnotation {
   
    let name        : String
    let link        : String
    let coordinate  : CLLocationCoordinate2D
    
    init(name : String, link : String, coordinate : CLLocationCoordinate2D) {
        self.name = name
        self.link = link
        self.coordinate = coordinate
    
        super.init()
    }
    
    var title : String {
        return name
    }
    
    var subtitle : String {
        return link
    }
}

class MapTabController : UIViewController,
                         MKMapViewDelegate {
    
    var studentAnnotations : [StudentAnnotation]! = []
   
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
        
        DataLoader.loadStudentLocations() { error in
            // XXX make this nicer
            if let errorMsg = error {
                var alert = UIAlertController(title: "Alert", message: errorMsg, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                self.refreshPins()
            }
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // actions
    //
    
    func annotationTapGesture(sender : AnyObject) {
        if let annotionView = sender.view as? MKAnnotationView {
            if let student = annotionView.annotation as? StudentAnnotation {
                UIApplication.sharedApplication().openURL(NSURL(string: student.link)!)
            }
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // MKMapViewDelegate
    //
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        if let student = annotation as? StudentAnnotation {
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
        
        // cleanup
        mapView.removeAnnotations(studentAnnotations)
        studentAnnotations.removeAll(keepCapacity: true)
        
        // build the list
        for student in DataContext.instance().studentLocations {
            studentAnnotations.append(StudentAnnotation(name: student.fullName(),
                                                        link: student.mediaURL,
                                                        coordinate: CLLocationCoordinate2D(latitude: student.latitude, longitude: student.longitude)))
        }
        
        mapView.addAnnotations(studentAnnotations)
    }
    
    
}