//
//  LogViewController.swift
//  ProjectTimer
//
//  Created by xcode on 3/6/15.
//  Copyright (c) 2015 MSCline. All rights reserved.
//

import UIKit

class LogViewController: UIViewController, UITableViewDataSource  {



        var selectedTimer:TrackingCategory?
        var logsToDisplay:NSArray?       // rem: stored in CoreData, which used ObjC

        @IBOutlet weak var tableView: UITableView!


    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    
        if selectedTimer != nil || selectedTimer!.categorysLogs != nil {

            let setLogsToDisplay = selectedTimer!.categorysLogs!
            logsToDisplay = setLogsToDisplay.allObjects
            tableView.reloadData()

        }

    }


    // MARK: TABLE VIEW DATASOURCE

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 2

    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        // if no data, tell table view 0 items to display
        if selectedTimer == nil || selectedTimer!.categorysLogs == nil {

            return 0

        }

        if section == 0 {

            return logsToDisplay!.count

        } else {

            return 1
        }

    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {


        if indexPath.section == 0 {

            return formatCellInSection0(tableView, cellForRowAtIndexPath: indexPath)

        }else if indexPath.section == 1 {

            return formatCellInSection1(tableView, cellForRowAtIndexPath: indexPath)

        }else{

            abort()  // we only are usng two sections
        }

    }

    func formatCellInSection0(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        // get cell to work with
        var cell = tableView.dequeueReusableCellWithIdentifier("logA", forIndexPath: indexPath) as LogTableViewCell

        // get data object
        let log = logsToDisplay?.objectAtIndex(indexPath.row) as LogRecord

        // format cell
        formatLogCell(cell, logRecord: log)

        // if editing make buttons clickable
        ifEditingAllowUserInteraction()

        return cell

    }

    func formatLogCell(cell:LogTableViewCell, logRecord:LogRecord)->(LogTableViewCell){

        cell.button_startTime.setTitle("a", forState: UIControlState.Normal)
        cell.button_startTime.setTitle("b", forState: UIControlState.Normal)
        //            = logRecord.checkinTime.timeIntervalSinceDate
        //        cell.button_endTime = logRecord.checkoutTime

        return cell

    }

    func formatDate(date:NSDate)->(String){

        
        return "s"
        
    }
    
    func ifEditingAllowUserInteraction(){
        
        
    }
    
    func formatCellInSection1(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("logB", forIndexPath: indexPath) as UITableViewCell
        
        return cell
        
    }


    // MARK: EDITING

    @IBAction func onDatePickerEntryCompleted(sender: UIDatePicker) {

        let updatedDate = sender.date

    }

}
