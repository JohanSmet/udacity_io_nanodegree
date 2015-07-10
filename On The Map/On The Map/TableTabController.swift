//
//  TableTabController.swift
//  On The Map
//
//  Created by Johan Smet on 26/06/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class TableTabController :  UIViewController,
                            AppDataTab,
                            UITableViewDelegate, UITableViewDataSource {
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // outlets
    //
    
    @IBOutlet weak var studentTable: UITableView!
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController overrides
    //
    
    override func viewDidLoad() {
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // AppDataTab overrides
    //
    
    func refreshData() {
        studentTable.reloadData()
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewDataSource overrides
    //
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataContext.instance().studentLocations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // get a cell
        let cell = tableView.dequeueReusableCellWithIdentifier("StudentCell") as! UITableViewCell 
        
        // set the cell data
        let student = DataContext.instance().studentByIndex(indexPath.row)!
        cell.textLabel?.text    = student.fullName()
        cell.imageView?.image   = UIImage(named: AssetIcons.Pin)
        
        return cell
    }

    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewDelegate overrides
    //
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let student = DataContext.instance().studentByIndex(indexPath.row)!
        UIApplication.sharedApplication().openURL(NSURL(string: student.mediaURL)!)
    }
    
}