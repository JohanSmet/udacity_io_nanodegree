//
//  MainViewController.swift
//  Virtual Tourist
//
//  Created by Johan Smet on 06/08/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class MainViewController: UIViewController,
                          MKMapViewDelegate {
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    private var mapTapRecognizer   : UILongPressGestureRecognizer?
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // outlets
    //

    @IBOutlet weak var mapView: MKMapView!
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create tap recognizer to add annotations to the map
        mapTapRecognizer = UILongPressGestureRecognizer(target: self, action: "handleMapTap:")
        mapView.addGestureRecognizer(mapTapRecognizer!)
        
        // mapview customization
        mapView.delegate = self
        
        // load pins from Core Data
        dataContext().fetchAllPins()
        mapView.addAnnotations(dataContext().pins)
    }

    ///////////////////////////////////////////////////////////////////////////////////
    //
    // MKMapViewDelegate
    //
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        if let pin = annotation as? Pin {
            let identifier = "touristPin"
            
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) {
                dequeuedView.annotation = annotation
                return dequeuedView
            } else {
                let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = false
                view.animatesDrop = pin.animate
                return view
            }
        }
        
        return nil;
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // actions
    //
    
    func handleMapTap(gestureReconizer: UILongPressGestureRecognizer) {
        
        if (gestureReconizer.state != UIGestureRecognizerState.Began) {
            return
        }
        
        // get the tapped coordinate
        let point = mapTapRecognizer!.locationInView(mapView)
        let coord = mapView.convertPoint(point, toCoordinateFromView: mapView)
        
        // add the pin to the map
        let pin = dataContext().createPin(coord.latitude, longitude: coord.longitude)
        mapView.addAnnotation(pin)
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // helper functions
    //
}

