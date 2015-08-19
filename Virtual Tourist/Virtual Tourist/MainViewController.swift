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
    private var currentPin         : Pin!
    
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
        restoreMapSettings()
        mapView.delegate = self
        
        // make sure core data can be initialised properly
        if coreDataStackManager().managedObjectContext == nil {
            alertOk(self, NSLocalizedString("conCoreDataError", comment: "Unable to initalize CoreData-backend"))
            return
        }
        
        // load pins from Core Data
        dataContext().fetchAllPins()
        mapView.addAnnotations(dataContext().pins)
        
        // load extra student information
        StudentDownloadService.downloadStudentLocations() { error in
            // don't pester user with error about an optional feature
        }
        
        // navigation controller
        let buttonBack = UIBarButtonItem(title: NSLocalizedString("conButtonOk", comment: "OK"), style: .Plain, target: self, action: "Back")
        self.navigationItem.backBarButtonItem = buttonBack
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
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
                view.animatesDrop   = pin.animate
                return view
            }
        }
        
        return nil;
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        let photoVC = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoViewController") as! PhotoViewController
        photoVC.pin = view.annotation as! Pin
        self.navigationController?.pushViewController(photoVC, animated: true)
        
        // automatically deselect the annotion so it can be selected again after returning to this view
        mapView.deselectAnnotation(view.annotation, animated: false)
    }
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        saveMapSettings()
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // actions
    //
    
    func handleMapTap(gestureReconizer: UILongPressGestureRecognizer) {
        
        // get the tapped coordinate
        let point = mapTapRecognizer!.locationInView(mapView)
        let coord = mapView.convertPoint(point, toCoordinateFromView: mapView)
        
        switch(gestureReconizer.state) {
            
            case .Began :
                // add the pin to the map
                currentPin = dataContext().createPin(coord.latitude, longitude: coord.longitude)
                mapView.addAnnotation(currentPin)
                break
            
            case .Changed :
                // move pin
                currentPin.setCoordinate(coord)
                break
            
            case .Ended :
                coreDataStackManager().saveContext()
                
                // start downloading photos for this location
                PhotoDownloadService.downloadPhotosForLocation(currentPin) { downloadError in
                    if let error = downloadError {
                        alertOkAsync(self, error)
                    }
                }
                break
            
            default :
                return
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // helper functions
    //
    
    func saveMapSettings() {
        let defaults = NSUserDefaults.standardUserDefaults();
        
        defaults.setBool(true, forKey: "mapview_saved")
        defaults.setDouble(mapView.region.center.latitude,     forKey: "mapview_latitude")
        defaults.setDouble(mapView.region.center.longitude,    forKey: "mapview_longitude")
        defaults.setDouble(mapView.region.span.latitudeDelta,  forKey: "mapview_latitude_delta")
        defaults.setDouble(mapView.region.span.longitudeDelta, forKey: "mapview_longitude_delta")
    }
    
    func restoreMapSettings() {
        let defaults = NSUserDefaults.standardUserDefaults();
        
        if !defaults.boolForKey("mapview_saved") {
            return
        }
        
        mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake( defaults.doubleForKey("mapview_latitude"),
                                                                            defaults.doubleForKey("mapview_longitude")),
                                                MKCoordinateSpanMake(defaults.doubleForKey("mapview_latitude_delta"),
                                                                     defaults.doubleForKey("mapview_longitude_delta")))
    }
}

