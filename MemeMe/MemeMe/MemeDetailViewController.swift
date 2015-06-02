//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Johan Smet on 25/05/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import UIKit
import Foundation

class MemeDetailViewController: UIViewController {
    
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // public data
    //
    
    var memeIndex : Int?
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // outlets
    //

    @IBOutlet weak var imageView: UIImageView!
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController overrides
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigation bar items
        let buttonEdit = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: "editMeme")
        let buttonDelete = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Trash, target: self, action: "deleteMeme")
        self.navigationItem.setRightBarButtonItems([buttonDelete, buttonEdit], animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        // load the image
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        imageView.image = appDelegate.memes[memeIndex!].memedImage
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "memeEditorSegue" {
            if let editorVC = segue.destinationViewController as? MemeEditorViewController {
                editorVC.memeIndex = self.memeIndex
            }
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // actions
    //

    func editMeme() {
        // meme to be edited is passed in prepareForSegue
        self.performSegueWithIdentifier("memeEditorSegue", sender: self)
    }
    
    func deleteMeme() {
        
        // confirmation dialog
        var deleteAlert = UIAlertController(title: "Delete", message: "The meme will be lost.", preferredStyle: UIAlertControllerStyle.Alert)
        
        deleteAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
            // remove the meme from the shared model
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.memes.removeAtIndex(self.memeIndex!)
            
            // close the detail view
            self.navigationController?.popViewControllerAnimated(true)
        }))
        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil));
        
        presentViewController(deleteAlert, animated: true, completion: nil)
    }

}

