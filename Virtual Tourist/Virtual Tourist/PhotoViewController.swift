//
//  PhotoViewController.swift
//  Virtual Tourist
//
//  Created by Johan Smet on 11/08/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class PhotoViewController : UIViewController,
                            UICollectionViewDataSource,
                            UICollectionViewDelegate,
                            NSFetchedResultsControllerDelegate {
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    var pin : Pin!
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        // fetchRequest.sortDescriptors = [NSSortDescriptor(key: "flickrUrl", ascending: true)]
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate       = NSPredicate(format: "location == %@", self.pin);
        
        let fetchedResultsController = NSFetchedResultsController (
                                            fetchRequest: fetchRequest,
                                            managedObjectContext: coreDataStackManager().managedObjectContext!,
                                            sectionNameKeyPath: nil,
                                            cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
   
    ////////////////////////////////////////////////////////////////////////////////
    //
    // outlets
    //
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // center the map on the selected pin
        setupMap(pin)
        
        // load the photo's from core data
        var error: NSError?
        fetchedResultsController.performFetch(&error)
        
        if let error = error {
            println("Error performing initial fetch: \(error)")
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Lay out the collection view so that cells take up 1/3 of the width, with no space in between.
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let size = floor(self.collectionView.frame.size.width/3)
        layout.itemSize = CGSize(width: size, height: size)
        collectionView.collectionViewLayout = layout
    }
    
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UICollectionViewDataSource overrides
    //
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        // get a cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCell
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        
        let documentsDirectory: AnyObject = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]
        let path = documentsDirectory.stringByAppendingPathComponent(photo.localUrl!)
        
        cell.image.image = UIImage(contentsOfFile: path)!
        
        return cell
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UICollectionViewDelegate overrides
    //
    
/*    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let detailView = self.storyboard?.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        detailView.memeIndex = indexPath.row
        self.navigationController?.pushViewController(detailView, animated: true)
    }*/
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // NSFetchedResultsControllerDeleage
    //
    
    // Step 4: This would be a great place to add the delegate methods
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        // self.collectionView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController,
                    didChangeObject anObject: AnyObject,
                    atIndexPath indexPath: NSIndexPath?,
                    forChangeType type: NSFetchedResultsChangeType,
                    newIndexPath: NSIndexPath?) {
            
        switch type {
                
            case .Insert:
                // collectionView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
                collectionView.insertItemsAtIndexPaths([newIndexPath!])
                
            // case .Delete:
            //    tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                
            case .Update:
                let cell = collectionView.cellForItemAtIndexPath(indexPath!) as! PhotoCell
                let photo = controller.objectAtIndexPath(indexPath!) as! Photo
                cell.image.image = UIImage(contentsOfFile: photo.localUrl!)!
            
            case .Move:
                collectionView.deleteItemsAtIndexPaths([indexPath!])
                collectionView.insertItemsAtIndexPaths([newIndexPath!])
                
            default:
                return
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        // self.tableView.endUpdates()
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // Actions
    //
    
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // Helper functions
    //
    
    private func setupMap(location : Pin) {
 
        // center on the location
        mapView.setRegion(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpanMake(0.05, 0.05)), animated: true)
        
        // add the pin to the map
        mapView.addAnnotation(location)
        
        // disable interaction
        mapView.zoomEnabled     = false
        mapView.scrollEnabled   = false
        mapView.pitchEnabled    = false
        mapView.rotateEnabled   = false
        
    }
}