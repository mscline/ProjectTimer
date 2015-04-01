//
//  LogViewController.swift
//  ProjectTimer
//
//  Created by xcode on 3/6/15.
//  Copyright (c) 2015 MSCline. All rights reserved.
//

import UIKit

enum editingMode{

    case notEditing
    case editing
    case picker
    case picker_doNotSave
}

class LogViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {


        @IBOutlet weak var tableView: UITableView!
        var isInEditingMode = editingMode.notEditing

        // display timers
        var selectedTimer:TrackingCategory?
        var logsToDisplay:NSArray?       // rem: stored in CoreData, which used ObjC
        let inProgressMessage = " ...in progress "

        // date picker
        // - we just have one picker that is hidden in the background and will be moved to correct location, making it look like it was placed in the table (we will resize tableview cell, for fit);
        // (a drawback is that we have to programatically set the cell size; alternatively, we could use sectons for each log and add a second row for the prototype cell)
        @IBOutlet weak var datePicker: UIDatePicker!
        var datePickerActingOnLog:LogRecord?
        var datePickerIsActingOnRowNumber:Int = -1
        var datePickerIsActingOnStartTimeNotEndTime = true

        @IBOutlet weak var viewToStoreTheDatePicker: UIView! // the date picker doesn't move correctly
        @IBOutlet weak var backgroundBlockerButton: UIButton!
        @IBOutlet weak var pickerYPosition: NSLayoutConstraint!


    // MARK: SETUP - get logs

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // hide date picker
        viewToStoreTheDatePicker.hidden = true
        backgroundBlockerButton.hidden = true

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

        // if in editing mode, add a second section where we can put editing controls
        // for the time being, we will add a row with an editing button
        if isInEditingMode == editingMode.notEditing {

            return 1;

        }else{

            return 2;
        }

    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        // if no data, tell table view 0 items to display
        if selectedTimer == nil || selectedTimer!.categorysLogs == nil || logsToDisplay == nil {

            return 0

        }

        if section == 0 {

            return logsToDisplay!.count

        }else if section == 1 {

            return 1
        }

        return 0

    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if indexPath.section == 0 {

            // get cell to work with
            var cell = tableView.dequeueReusableCellWithIdentifier("logA", forIndexPath: indexPath) as LogTableViewCell

            // get data object
            let log = logsToDisplay?.objectAtIndex(indexPath.row) as LogRecord

            // format cell
            formatLogCell(cell, logRecord: log)
            addTagsSoCanLookupCorrespondingDataObject(cell: cell, indexPath: indexPath)

            // if editing make buttons clickable
            ifEditingAllowUserInteractionAndChangeTextColor(cell: cell, indexPath: indexPath)

            return cell

        }else if indexPath.section == 1 {

            var cell2 = tableView.dequeueReusableCellWithIdentifier("addButton", forIndexPath: indexPath) as AddButtonTableViewCell
            cell2.button.setTitleColor(UIColor.greenColor(), forState: UIControlState.Normal)
            return cell2

        } else {

            return UITableViewCell()
        }

    }

    func formatLogCell(cell:LogTableViewCell, logRecord:LogRecord)->(LogTableViewCell){


        let startTime = formatDate(logRecord.checkinTime)
        var endTime:String = inProgressMessage

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

    func ifEditingAllowUserInteractionAndChangeTextColor(#cell:LogTableViewCell, indexPath:NSIndexPath){

        if isInEditingMode == editingMode.editing {

            cell.button_startTime.userInteractionEnabled = true
            cell.button_endTime.userInteractionEnabled = true

            // use setter methods instead
            cell.button_startTime.tintColor = UIColor.orangeColor()
            cell.button_endTime.tintColor = UIColor.orangeColor()

            cell.button_deleteLog.hidden = false


        }else if isInEditingMode == editingMode.notEditing {

            cell.button_startTime.userInteractionEnabled = false
            cell.button_endTime.userInteractionEnabled = false

            cell.button_startTime.tintColor = UIColor.blueColor()
            cell.button_endTime.tintColor = UIColor.blueColor()

            cell.button_deleteLog.hidden = true

        }

    }


    // MARK: TABLEVIEW DELEGATE METHOD

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        var rowHeight:CGFloat = 44  // ???? JUST WENT WITH HARDCODE, BUT NOT IDEAL

        if indexPath.row == datePickerIsActingOnRowNumber {

            rowHeight = datePicker.frame.size.height + rowHeight

        }

        return rowHeight;

    }


    // MARK: EDITING

    func changeEditingMode(){

        // 1) make necessary changes before leaving view
        //    (better to put code in when entering new mode than when leaving)

        if isInEditingMode == editingMode.editing {

            // do nothing

        } else if isInEditingMode == editingMode.notEditing{

            // do nothing

        } else if isInEditingMode == editingMode.picker {

            fixerMethod_changeButtonColorsForRow(datePickerIsActingOnRowNumber, color: UIColor.orangeColor())

            // need to save
            leavingPickerMode()

        } else if isInEditingMode == editingMode.picker_doNotSave {

            fixerMethod_changeButtonColorsForRow(datePickerIsActingOnRowNumber, color: UIColor.orangeColor())
            hideDatePicker()
            isInEditingMode = editingMode.picker

        }


        // 2) switch into appropriate mode

        if isInEditingMode == editingMode.notEditing {

            isInEditingMode = editingMode.editing

        }else if isInEditingMode == editingMode.editing {

            isInEditingMode = editingMode.notEditing

        }else if isInEditingMode == editingMode.picker {

            isInEditingMode = editingMode.editing

        }


        // 3) make appropriate changes depending on which mode you are in

        if isInEditingMode == editingMode.editing {

            enteringEditingMode()

        } else if isInEditingMode == editingMode.notEditing{

            enteringNonEditingMode()

        } else if isInEditingMode == editingMode.picker {

            // unused
        }

        // reload data (table view will display differently, depending on mode)
        tableView.reloadData()

    }

    func fixerMethod_changeButtonColorsForRow(row:Int, color:UIColor){

        let indexPath = NSIndexPath(forRow:row, inSection:0)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as LogTableViewCell

        cell.button_startTime.tintColor = color;
        cell.button_endTime.tintColor = color;

    }

    func enteringEditingMode(){

        navigationItem.rightBarButtonItem?.title = "Done"
        navigationItem.rightBarButtonItem?.tintColor = UIColor.orangeColor()

        // set tint color
        let window = UIApplication.sharedApplication().delegate?.window!
        window?.tintColor = UIColor.orangeColor()

    }

    func enteringNonEditingMode(){

        navigationItem.rightBarButtonItem?.title = "Edit"

        // set tint color
        let window = UIApplication.sharedApplication().delegate?.window!
        window?.tintColor = UIColor.blueColor()

    }

    func enteringPickerMode(){

        navigationItem.rightBarButtonItem?.title = "Save"
        navigationItem.rightBarButtonItem?.tintColor = UIColor.greenColor()

    }

    func leavingPickerMode(){

        savePickerData()
        hideDatePicker()

    }

    func addNewLog(){

        let now = NSDate()
        let record = LogRecordSubclass.addNewLogRecord(checkinTime: now, parentCategory: selectedTimer!)

        // logs not created with a checkout date, so add it (it should be the same as the start date)
        record.checkoutTime = NSDate().dateByAddingTimeInterval(0.0)

        // save
        var err = NSErrorPointer()
        LogRecordSubclass.getMOC().save(err)

    }


    // MARK: BUTTONS

    @IBAction func onEditButtonPressed(sender: AnyObject) {

        changeEditingMode()

    }

    @IBAction func onDeleteButtonPressed(sender: UIButton) {

        let logForDeletion = logsToDisplay?.objectAtIndex(sender.tag) as LogRecord
        LogRecordSubclass.delLogRecord(obj: logForDeletion)
        reloadTableWithUpdatedData()

    }

    @IBAction func backgroundTouched(sender: AnyObject) {

        // cancel
        isInEditingMode = editingMode.picker_doNotSave
        changeEditingMode()

    }

    @IBAction func onAddButtonPressed(sender: AnyObject) {

        addNewLog()
        reloadTableWithUpdatedData()

    }

    // MARK: DATE PICKER

    @IBAction func onStartTimeButtonPressed(sender: UIButton) {

        datePickerIsActingOnStartTimeNotEndTime = true
        datePickerActingOnLog = logsToDisplay?.objectAtIndex(sender.tag) as? LogRecord
        datePicker.date = datePickerActingOnLog!.checkinTime

        showDatePicker(sender:sender)

        // temporarily change the tint color
        for view in sender.superview!.subviews {

            let ourView = view as UIView
            ourView.tintColor = UIColor.orangeColor()

        }
        sender.tintColor = UIColor.greenColor()

    }

    @IBAction func onCheckoutTimeButtonPressed(sender: UIButton) {

        datePickerIsActingOnStartTimeNotEndTime = false
        datePickerActingOnLog = logsToDisplay?.objectAtIndex(sender.tag) as? LogRecord

        if datePickerActingOnLog!.checkoutTime != nil {

            datePicker.date = datePickerActingOnLog!.checkoutTime

        }

        showDatePicker(sender:sender)

        // temporarily change the tint color
        sender.tintColor = UIColor.greenColor()
    }

    func showDatePicker(#sender:UIButton){

        // setup
        isInEditingMode = editingMode.picker
        enteringPickerMode()

        // move picker into correct location
        setPickerPosition(sender: sender)
        viewToStoreTheDatePicker.hidden = false
        backgroundBlockerButton.hidden = false

        // reload table with greater height (not reload row, animation looks weird)
        let indexPath = NSIndexPath(forRow: sender.tag, inSection: 0)
        datePickerIsActingOnRowNumber = indexPath.row  // on reload, the table view will check to see if the picker should be showing

        tableView.reloadData()  // just load the whole thing, or looks weird

        // scroll table
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)



    }

    func setPickerPosition(#sender:UIButton){


        // move picker to correct position above tableV row
        let superView = sender.superview! as UIView  // need to cast or get weird error
        let originOfButtonInAbsCoord = superView.convertPoint(superView.frame.origin, toView: nil)

        let picker_desiredYComponent = CGFloat(originOfButtonInAbsCoord.y + sender.frame.height)
        pickerYPosition.constant = picker_desiredYComponent + 8.0


        // if off screen, move back up
        if pickerYPosition.constant > self.view.frame.height - datePicker.frame.height {

            pickerYPosition.constant = self.view.frame.height - datePicker.frame.height - self.navigationController!.toolbar.frame.size.height - 10.0  // just looks a little off so adjust

        }

    }

    func savePickerData(){

        if checkForInvalidDates() == false {

            _saveLogRecordWithUpdatedPickerDate()
            hideDatePicker()

        }else{

            var alert = UIAlertController(title: "Error", message: "Your checkout date must be after your check-in date.", preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler:nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: { () -> Void in  })
        }
    }

    func checkForInvalidDates()->(Bool){

        var startTime:NSDate?
        var finishTime:NSDate?

        // check to make sure that the checkout time is not before the checkin
        if datePickerIsActingOnStartTimeNotEndTime == true {

            startTime = datePicker.date
            finishTime = datePickerActingOnLog?.checkoutTime

        } else {

            startTime = datePickerActingOnLog?.checkinTime
            finishTime = datePicker.date

        }

        // if finish time is before start time, exit
        if finishTime != nil   &&
            finishTime!.timeIntervalSince1970 < startTime!.timeIntervalSince1970 {
                
                // report that this is an invalid date
                return true
                
        }
        
        return false
    }
    
    func _saveLogRecordWithUpdatedPickerDate() {
        
        // set checkInTime or checkoutTime appropriately
        if datePickerIsActingOnStartTimeNotEndTime == true {
            
            datePickerActingOnLog?.checkinTime = datePicker.date
            
        } else {
            
            datePickerActingOnLog?.checkoutTime = datePicker.date
            
        }
        
        // save
        let err = NSErrorPointer()
        LogRecordSubclass.getMOC().save(err)
        
    }
    
    func hideDatePicker(){
        
        // hide picker
        viewToStoreTheDatePicker.hidden = true
        backgroundBlockerButton.hidden = true
        
        // update table w/o space
        datePickerIsActingOnRowNumber = -1
        tableView.reloadData()
        
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
       // self.navigationController?.popToRootViewControllerAnimated(false)
        
    }
    
    
    // MARK: TRANSITIONS
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        if isInEditingMode == editingMode.picker || isInEditingMode == editingMode.picker_doNotSave {
            
            isInEditingMode = editingMode.picker_doNotSave
            changeEditingMode()
            
        }
        
    }
    
}

