//
//  SentMemesTableViewController.swift
//  MemeMe
//
//  Created by Johan Smet on 24/05/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import UIKit

class SentMemesTableViewController: UIViewController,
                                    UITableViewDelegate, UITableViewDataSource {


    ///////////////////////////////////////////////////////////////////////////////////
    //
    // outlets
    //
    
    @IBOutlet weak var memeTable: UITableView!
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController overrides
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
       
        memeTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "SentMemeTableCell")
    }
    
    override func viewDidAppear(animated: Bool) {
        memeTable.reloadData()
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewDataSource overrides
    //
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.memes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // get a cell
        let cell = tableView.dequeueReusableCellWithIdentifier("SentMemeTableCell") as! UITableViewCell
        
        // set the cell data
        let meme = appDelegate.memes[indexPath.row]
        
        cell.imageView?.image = meme.image
        cell.textLabel?.text = meme.topText + " " + meme.bottomText
        
        return cell
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewDelegate
    //

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let detailView = self.storyboard?.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        detailView.memeImage = appDelegate.memes[indexPath.row].memedImage
        self.navigationController?.pushViewController(detailView, animated: true)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // private data
    //
    
    var appDelegate : AppDelegate!
    
}
