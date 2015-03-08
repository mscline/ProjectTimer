//
//  LogViewController.swift
//  ProjectTimer
//
//  Created by xcode on 3/6/15.
//  Copyright (c) 2015 MSCline. All rights reserved.
//

import UIKit

class LogViewController: UIViewController, UITableViewDataSource  {


        // display timers
        var selectedTimer:TrackingCategory?
        var logsToDisplay:NSArray?       // rem: stored in CoreData, which used ObjC

        // outlets
        @IBOutlet weak var tableView: UITableView!


    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)


        getLogs()
        sortLogs()

    }

    func getLogs(){

        if selectedTimer != nil || selectedTimer!.categorysLogs != nil {

            let setLogsToDisplay = selectedTimer!.categorysLogs!
            logsToDisplay = setLogsToDisplay.allObjects
            tableView.reloadData()
            
        }
    }

    func sortLogs(){

        if logsToDisplay == nil { return;}

        logsToDisplay = logsToDisplay!.sortedArrayUsingComparator({ (objA, objB) -> NSComparisonResult in

            let recordA = objA as LogRecord
            let timeA = recordA.checkinTime.timeIntervalSince1970

            let recordB = objB as LogRecord
            let timeB = recordB.checkinTime.timeIntervalSince1970

            if timeA >= timeB {

                return NSComparisonResult.OrderedDescending

            } else {

                return NSComparisonResult.OrderedAscending

            }

        })
    }


    // MARK: TABLE VIEW DATASOURCE

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 1

    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        // if no data, tell table view 0 items to display
        if selectedTimer == nil || selectedTimer!.categorysLogs == nil {

            return 0

        } else {

            return logsToDisplay!.count

        }

    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {


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


        let startTime = formatDate(logRecord.checkinTime)
        var endTime:String = " . . . "

        let checkoutDate = logRecord.checkoutTime
        if checkoutDate != nil {

            endTime = formatDate(checkoutDate!)

        }


        cell.button_startTime.setTitle(startTime, forState: UIControlState.Normal)
        cell.button_endTime.setTitle(endTime, forState: UIControlState.Normal)

        return cell

    }

    func formatDate(date:NSDate)->(String){

        let dateString = NSDateFormatter.localizedStringFromDate(date, dateStyle: NSDateFormatterStyle.ShortStyle, timeStyle: NSDateFormatterStyle.ShortStyle)

        return dateString

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
