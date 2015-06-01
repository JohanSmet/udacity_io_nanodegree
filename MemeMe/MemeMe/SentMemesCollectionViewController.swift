//
//  SentMemesCollectionViewController.swift
//  MemeMe
//
//  Created by Johan Smet on 25/05/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import UIKit

class SentMemesCollectionViewController: UIViewController,
                                         UICollectionViewDataSource,
                                         UICollectionViewDelegate
{
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // outlets
    //
    
    @IBOutlet weak var memeCollection: UICollectionView!

    ///////////////////////////////////////////////////////////////////////////////////
    //
    // constants
    //
    
    let cellReuseIdentifier : String = "SentMemeCollectionCell"

    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController overrides
    //

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    override func viewDidAppear(animated: Bool) {
        memeCollection.reloadData()
    }

    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UICollectionViewDataSource overrides
    //
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return appDelegate.memes.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        // get a cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! MemeCollectionCell
        
        // set the cell data
        let meme = appDelegate.memes[indexPath.row]
        cell.image.image = meme.memedImage
    
        return cell
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UICollectionViewDelegate overrides
    //

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let detailView = self.storyboard?.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        detailView.memeIndex = indexPath.row
        self.navigationController?.pushViewController(detailView, animated: true)
    }

    ///////////////////////////////////////////////////////////////////////////////////
    //
    // private data
    //
    
    var appDelegate : AppDelegate!
}

