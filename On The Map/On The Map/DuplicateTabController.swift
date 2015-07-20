//
//  DuplicateTabController.swift
//  On The Map
//
//  Created by Johan Smet on 10/07/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import Foundation
import UIKit

class DublicateTabController :  UIViewController,
                                AppDataTab,
                                UITableViewDelegate, UITableViewDataSource {
   
    
    var sectionMap : [ Int : [StudentInformation] ] = [:]
    var sections   : [ Int ] = []
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // outlets
    //
    
    @IBOutlet weak var studentTable: UITableView!
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController overrides
    //
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // for some reason the top content-inset is set when returning from the InformationPosting-view
        // (when time permits we should find the real cause of this problem)
        studentTable.contentInset.top = 0
        
        // refresh the locally cached data 
        refreshData()
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // AppDataTab overrides
    //
    
    func refreshData() {
        // clear previous data
        sectionMap.removeAll(keepCapacity: true)
        
        // reformat the data to a more appropriate structure
        for student in DataContext.instance().studentLocations {
            if student.occurances > 1 {
                if var section = sectionMap[student.occurances] {
                    sectionMap[student.occurances]?.append(student)
                } else {
                    sectionMap[student.occurances] = [student]
                }
            }
        }
        
        // create a sorted section array
        sections = sorted (sectionMap.keys.array, { return $0 > $1 })
        
        // update screen
        studentTable.reloadData()
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewDataSource overrides
    //
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(sections[section]) records"
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionId   = sections[section]
        let sectionList = sectionMap[sectionId]!
        return sectionList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // get a cell
        let cell = tableView.dequeueReusableCellWithIdentifier("StudentCell") as! UITableViewCell
        
        // set the cell data
        let section = sectionMap[sections[indexPath.section]]!
        let student = section[indexPath.row]
        cell.textLabel?.text    = student.fullName()
        cell.imageView?.image   = UIImage(named: AssetIcons.Pin)
        
        return cell
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITableViewDelegate overrides
    //
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let section = sectionMap[sections[indexPath.section]]!
        let student = section[indexPath.row]
        
        if isValidUrl(student.mediaURL) {
            UIApplication.sharedApplication().openURL(NSURL(string: student.mediaURL)!)
        } else {
            alertOkAsync(self, NSLocalizedString("conInvalidURL", comment: "Invalid URL!"))
        }
    }
}