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

class InformationPostingController: UIViewController,
                                    UITextViewDelegate,
                                    BrowseLinkResultDelegate {
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // outlets
    //

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerLocation: UIView!
    @IBOutlet weak var containerLink: UIView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var headerText: UILabel!
    @IBOutlet weak var locationText: UITextView!
    @IBOutlet weak var locationPlaceholder: UILabel!
    @IBOutlet weak var linkText: UITextView!
    @IBOutlet weak var linkPlaceholder: UILabel!
    
    @IBOutlet weak var buttonSubmit: UIButton!
    @IBOutlet weak var buttonFindOnMap: UIButton!
    @IBOutlet weak var buttonBrowseLink: UIButton!
    
    @IBOutlet weak var indicatorGeocoding: UIActivityIndicatorView!
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    private var locationCoordinate : CLLocationCoordinate2D?
    private var keyboardFix : KeyboardFix!
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController overrides
    //
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // UI tweaks
        styleButton(buttonSubmit)
        styleButton(buttonFindOnMap)
        styleButton(buttonBrowseLink)
        
        // show the information previously entered by the user
        if let userLocation = DataContext.instance().userLocation {
            locationText.text = userLocation.mapString
            linkText.text = userLocation.mediaURL
        }
        
        // header-text
        headerText.attributedText = attributedHeaderText()
        
        // location-entry
        locationPlaceholder.hidden = !locationText.text.isEmpty
        locationText.delegate = self
        
        // link-entry
        linkPlaceholder.hidden = !linkText.text.isEmpty
        linkText.delegate = self
        
        // make sure to show the correct view
        containerLocation.hidden = false
        containerLink.hidden = true
        self.view.backgroundColor = containerLocation.backgroundColor
        
        // keyboard handling
        keyboardFix = KeyboardFix(viewController: self, scrollView: scrollView)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // keyboard handling
        keyboardFix.activate()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        keyboardFix.deactivate()
    }
   
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == ViewSegues.BrowseForLink {
            let browseLinkVC = segue.destinationViewController as! BrowseLinkController
            browseLinkVC.link = linkText.text
            browseLinkVC.delegate = self
        }
        
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITextViewDelegate overrides
    //
    
    func textViewDidChange(textView: UITextView) {
        if textView == locationText {
            locationPlaceholder.hidden = !locationText.text.isEmpty
        } else if textView == linkText {
            linkPlaceholder.hidden = !linkText.text.isEmpty
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        keyboardFix.setActiveControl(textView)
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        keyboardFix.setActiveControl(nil)
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        let resultRange = text.rangeOfCharacterFromSet(NSCharacterSet.newlineCharacterSet(), options: .BackwardsSearch)
        
        if (count(text) == 1 && resultRange != nil) {
            textView.resignFirstResponder()
            return false;
        }
        
        return true;
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // BrowseLinkResultDelegate overrides
    //
    
    func selectedURL(urlString: String) {
        linkText.text = urlString
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
            alertOkAsync(self, NSLocalizedString("conLocationRequired", comment:"You must enter a location before you can continue!"))
            return
        }
        
        indicatorGeocoding.hidden = false
        
        // geocode
        geocodeLocation(locationText.text!) { error in
            
            if let error = error {
                alertOkAsync(self, error.localizedFailureReason!)
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
                self.view.backgroundColor = self.containerLink.backgroundColor
            }
        }
    }

    @IBAction func submitLocation(sender: AnyObject) {
       
        // did the user enter a link
        if linkText.text!.isEmpty {
            return alertOkAsync(self, NSLocalizedString("conLinkRequired", comment:"You must enter a link before you can continue!"))
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
                return alertOkAsync(self, error)
            }
           
            if let objectId = objectId {
                DataContext.instance().userLocation!.objectId = objectId
            }
            
            self.dismissViewControllerAnimated(true, completion: nil)
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
    
    private func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    private func attributedHeaderText() -> NSAttributedString {
        // in code because it's easier to localize a UITextView than in Interface builder
        let colorLight : UIColor = UIColorFromRGB(0x99A9B8)
        let fontLight  : UIFont  = UIFont(name: "TrebuchetMS", size: 22.0)!
        
        let colorDark : UIColor = UIColorFromRGB(0x0F2F5D)
        let fontDark  : UIFont  = UIFont(name: "TrebuchetMS-Bold", size: 22.0)!
        
        
        let line1 = NSAttributedString(string: NSLocalizedString("conSubmitHeader1", comment: "Where are you") + "\n",
                                       attributes: [NSForegroundColorAttributeName : colorLight,
                                                    NSFontAttributeName: fontLight])
        
        let line2 = NSAttributedString(string: NSLocalizedString("conSubmitHeader2", comment: "studying") + "\n",
                                       attributes: [NSForegroundColorAttributeName : colorDark,
                                                    NSFontAttributeName: fontDark])
        
        let line3 = NSAttributedString(string: NSLocalizedString("conSubmitHeader3", comment: "today?"),
                                       attributes: [NSForegroundColorAttributeName : colorLight,
                                                    NSFontAttributeName: fontLight])
        
        let line = NSMutableAttributedString(attributedString: line1)
        line.appendAttributedString(line2)
        line.appendAttributedString(line3)
        
        return line
        
    }
}

