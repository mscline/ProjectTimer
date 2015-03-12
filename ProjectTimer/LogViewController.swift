//
//  LogViewController.swift
//  ProjectTimer
//
//  Created by xcode on 3/6/15.
//  Copyright (c) 2015 MSCline. All rights reserved.
//

import UIKit

class LogViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {


        @IBOutlet weak var tableView: UITableView!
        var isInEditingMode = false

        // display timers
        var selectedTimer:TrackingCategory?
        var logsToDisplay:NSArray?       // rem: stored in CoreData, which used ObjC


        // date picker 
        // - we just have one picker that is hidden in the background and will be moved to correct location, making it look like it was placed in the table (we will resize tableview cell, for fit);
        // (a drawback is that we have to programatically set the cell size; alternatively, we could use sectons for each log and add a second row for the prototype cell)
        @IBOutlet weak var datePicker: UIDatePicker!
        var datePickerActingOnLog:LogRecord?
        var datePickerIsActingOnRowNumber:Int = -1
        var datePickerIsActingOnStartTimeNotEndTime = true

        @IBOutlet weak var viewToStoreTheDatePicker: UIView! // the date picker doesn't move correctly
        @IBOutlet weak var backgroundBlockerButton: UIButton!

        //@IBOutlet weak var pickerYPosition: NSLayoutConstraint!
        // WRONG won't let attach to margins !!!


    // MARK: SETUP - get logs

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // hide date picker
        viewToStoreTheDatePicker.hidden = true
        //blockerView.hidden = true

        // set tint color
        let window = UIApplication.sharedApplication().delegate?.window!
        window?.tintColor = UIColor.blueColor()

        reloadTableWithUpdatedData()

    }

    func reloadTableWithUpdatedData(){

        getLogs()
        sortLogs()
        tableView.reloadData()

    }

    func getLogs(){

        if selectedTimer != nil || selectedTimer!.categorysLogs != nil {

            let setLogsToDisplay = selectedTimer!.categorysLogs!
            logsToDisplay = setLogsToDisplay.allObjects
            
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
        if selectedTimer == nil || selectedTimer!.categorysLogs == nil || logsToDisplay == nil {

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
        addTagsSoCanLookupCorrespondingDataObject(cell: cell, indexPath: indexPath)

        // if editing make buttons clickable
        ifEditingAllowUserInteraction(cell: cell, indexPath: indexPath)

        return cell

    }

    func formatLogCell(cell:LogTableViewCell, logRecord:LogRecord)->(LogTableViewCell){


        let startTime = formatDate(logRecord.checkinTime)
        var endTime:String = " ...in progress "

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


    func addTagsSoCanLookupCorrespondingDataObject(#cell:LogTableViewCell, indexPath:NSIndexPath){

        cell.button_deleteLog.tag = indexPath.row
        cell.button_startTime.tag = indexPath.row
        cell.button_endTime.tag = indexPath.row
        
    }

    func ifEditingAllowUserInteraction(#cell:LogTableViewCell, indexPath:NSIndexPath){

        if isInEditingMode == true {

            cell.button_startTime.userInteractionEnabled = true
            cell.button_endTime.userInteractionEnabled = true

        // use setter methods instead
            cell.button_startTime.titleLabel!.textColor = UIColor.orangeColor()
            cell.button_endTime.titleLabel!.textColor = UIColor.orangeColor()

            cell.button_deleteLog.hidden = false


        }else{

            cell.button_startTime.userInteractionEnabled = false
            cell.button_endTime.userInteractionEnabled = false

            cell.button_startTime.titleLabel!.textColor = UIColor.blueColor()
            cell.button_endTime.titleLabel!.textColor = UIColor.blueColor()

            cell.button_deleteLog.hidden = true

        }
        
    }


    // MARK: TABLEVIEW DELEGATE METHOD

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        var rowHeight:CGFloat = 44  // ????

        if indexPath.row == datePickerIsActingOnRowNumber {

            rowHeight = datePicker.frame.size.height + rowHeight

        }

        return rowHeight;

    }


    // MARK: EDITING

    @IBAction func onEditButtonPressed(sender: AnyObject) {


        // toggle isInEditingMode and change button title
        isInEditingMode = !isInEditingMode

        if isInEditingMode == true {

            navigationItem.rightBarButtonItem?.title = "Done"

            // set tint color
            let window = UIApplication.sharedApplication().delegate?.window!
            window?.tintColor = UIColor.orangeColor()

        } else {

            navigationItem.rightBarButtonItem?.title = "Edit"

            // set tint color
            let window = UIApplication.sharedApplication().delegate?.window!
            window?.tintColor = UIColor.blueColor()

        }

        // reload data (table view will display differently, depending on mode)
        tableView.reloadData()

    }

    @IBAction func onDeleteButtonPressed(sender: UIButton) {

        let logForDeletion = logsToDisplay?.objectAtIndex(sender.tag) as LogRecord
        LogRecordSubclass.delLogRecord(obj: logForDeletion)
        reloadTableWithUpdatedData()

    }

    @IBAction func backgroundTouched(sender: AnyObject) {

        hideDatePicker()
    }

    // MARK: DATE PICKER

    @IBAction func onStartTimeButtonPressed(sender: UIButton) {

        datePickerIsActingOnStartTimeNotEndTime = true
        datePickerActingOnLog = logsToDisplay?.objectAtIndex(sender.tag) as? LogRecord

        showDatePicker(sender:sender)

    }

    @IBAction func onCheckoutTimeButtonPressed(sender: UIButton) {

        datePickerIsActingOnStartTimeNotEndTime = false
        datePickerActingOnLog = logsToDisplay?.objectAtIndex(sender.tag) as? LogRecord

        showDatePicker(sender:sender)

    }

    func showDatePicker(#sender:UIButton){

        // move picker to correct position above tableV row
        let superView = sender.superview! as UIView  // need to cast or get weird error
        let originOfButtonInAbsCoord = superView.convertPoint(superView.frame.origin, toView: nil)

        let picker_desiredYComponent = CGFloat(originOfButtonInAbsCoord.y + sender.frame.height)
        ppickerYPosition.constant = picker_desiredYComponent
        viewToStoreTheDatePicker.hidden = false
        backgroundBlockerButton.hidden = false


        // reload table with greater height (not reload row, animation looks weird)
        let indexPath = NSIndexPath(forRow: sender.tag, inSection: 0)
        datePickerIsActingOnRowNumber = indexPath.row  // on reload, the table view will check to see if the picker should be showing

        let arrayOfPaths:NSArray = [indexPath]
        tableView.reloadData()

    }

    func hideDatePicker(){

        // hide picker

        // update table w/o space

    }

    @IBAction func onDatePickerEntryCompleted(sender: UIDatePicker) {

        let updatedDate = sender.date

        // delete old data
        datePickerIsActingOnRowNumber = -1
        datePickerActingOnLog = nil
    }


    // MARK: LIFECYCLE

    override func viewWillDisappear(animated: Bool) {

        // dismiss controller (always want to start with the root)
        self.navigationController?.popToRootViewControllerAnimated(false)
        
    }

}
