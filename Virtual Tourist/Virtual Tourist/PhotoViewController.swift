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
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "flickrUrl", ascending: true)]
        fetchRequest.predicate       = NSPredicate(format: "location == %@", self.pin);
        
        let fetchedResultsController = NSFetchedResultsController (
                                            fetchRequest: fetchRequest,
                                            managedObjectContext: coreDataStackManager().managedObjectContext!,
                                            sectionNameKeyPath: nil,
                                            cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    var insertedItems : [NSIndexPath]!
    var updatedItems  : [NSIndexPath]!
    var deletedItems  : [NSIndexPath]!
    
    var selectedPhotos : [Photo] = [Photo]()
   
    ////////////////////////////////////////////////////////////////////////////////
    //
    // outlets
    //
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    @IBOutlet weak var labelNoImages: UILabel!
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.allowsMultipleSelection = true
        
        // center the map on the selected pin
        setupMap(pin)
        
        // load the photo's from core data
        var error: NSError?
        fetchedResultsController.performFetch(&error)
        
        if let error = error {
            alertOk(self, error.localizedDescription);
        }
        
        // do some UI tweaks based on the available photos
        checkActionButton()
        labelNoImages.hidden = pin.photos.count > 0
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
       
        if let localUrl = photo.localUrl {
            let documentsDirectory: AnyObject = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]
            let path = documentsDirectory.stringByAppendingPathComponent(localUrl)
            
            cell.stateImage(path)
        } else {
            cell.stateWaiting()
        }
        
        if let foundIndex = find(selectedPhotos, photo) {
            cell.stateSelected()
        }
        
        return cell
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UICollectionViewDelegate overrides
    //
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? PhotoCell,
           let photo = fetchedResultsController.objectAtIndexPath(indexPath) as? Photo  {
            cell.stateSelected()
            selectPhoto(photo)
        }
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? PhotoCell,
           let photo = fetchedResultsController.objectAtIndexPath(indexPath) as? Photo  {
            cell.stateDeselected()
            deselectPhoto(photo)
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // NSFetchedResultsControllerDelegate
    //
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        // init array to buffer the changes
        insertedItems = [NSIndexPath]()
        updatedItems  = [NSIndexPath]()
        deletedItems  = [NSIndexPath]()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject,
                    atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType,
                    newIndexPath: NSIndexPath?) {
            
        switch type {
                
            case .Insert:
                insertedItems.append(newIndexPath!)
            
            case .Update:
                updatedItems.append(indexPath!)
            
            case .Delete :
                deletedItems.append(indexPath!)
            
            default:
                return
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        collectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedItems {
                self.collectionView.insertItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.deletedItems {
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.updatedItems {
                self.collectionView.reloadItemsAtIndexPaths([indexPath])
            }
            
        }, completion: nil)
        
        checkActionButton()
        labelNoImages.hidden = pin.photos.count > 0
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //
    // Actions
    //
    
    @IBAction func doActionButton(sender: UIBarButtonItem) {
        if selectedPhotos.count > 0 {
            removeSelectedPhotos()
        } else {
            downloadNewCollection()
        }
    }
    
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
    
    private func selectPhoto(photo : Photo) {
        selectedPhotos.append(photo)
        updateActionButtonTitle()
    }
    
    private func deselectPhoto(photo : Photo) {
        if let foundIndex = find(selectedPhotos, photo) {
            selectedPhotos.removeAtIndex(foundIndex)
        }
        
        updateActionButtonTitle()
    }
    
    private func checkActionButton() {
        actionButton.enabled = dataContext().allPhotosOfPinComplete(pin)
    }
   
    private func updateActionButtonTitle() {
        
        if selectedPhotos.count > 0 {
            actionButton.title = NSLocalizedString("conRemoveSelected", comment:"Remove Selected Pictures")
        } else {
            actionButton.title = NSLocalizedString("conNewCollection", comment:"New Collection")
        }
    }
    
    private func removeSelectedPhotos() {
        dataContext().deletePhotos(selectedPhotos)
        selectedPhotos.removeAll(keepCapacity: true)
        
        updateActionButtonTitle()
        labelNoImages.hidden = pin.photos.count > 0
    }
    
    private func downloadNewCollection() {
        dataContext().deletePhotosOfPin(pin)
        
        PhotoDownloadService.downloadPhotosForLocation(pin) { error in
            if let error = error {
                alertOkAsync(self, error);
            }
        }
    }
}