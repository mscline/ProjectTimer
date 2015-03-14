//
//  TimerViewController.swift
//  PieChart
//
//  Created by xcode on 2/17/15.
//  Copyright (c) 2015 MSCline. All rights reserved.
//



// WE CAN TRACK DIFFERENT CATEGORIES USING OUR TIMERS
// CATEGORIES ARE AVAILABLE TO BE USED BY PIE CHARTS

// A CATEGORY HAS A TITLE, TOTAL VALUE, AND COLOR

import UIKit

class TimerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {


        // INSTANCE VARIABLES
        var categories:NSArray?
        var colors:NSArray?
        var colorNames:NSArray?

        var selectedCategory:TrackingCategory?
        var logRecord:LogRecord?

        // CLOCK
        var elapsedTimeForSelectedCategory = 0.0
        var clockLabelToUpdate:UILabel?
        var correctClockLabelTagNumber:Int?    // used to check not updating reused cell item
        var clockTickEveryXSeconds = 0.01

        // EDITING MODE
        var editingModeIsOn = false

        // OUTLETS
        @IBOutlet weak var collectionV: UICollectionView!
        @IBOutlet weak var stopButton: UIButton!

        // CONSTANTS
        let defaultAlpha:CGFloat = 0.58


    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        reloadData()

        // set up timer to notify you every x seconds
        // use to increment category's clock
        NSTimer.scheduledTimerWithTimeInterval(clockTickEveryXSeconds, target: self, selector: "clockTick", userInfo: nil, repeats: true)

    }

    func reloadData(){

        getListOfCategoriesAndCheckToSeeIfTimerRunning()
        collectionV.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 102/255.0, alpha: defaultAlpha)  
        collectionV.reloadData()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        stopButton.layer.cornerRadius = 5
    }

    override func viewDidAppear(animated: Bool) {

        if editingModeIsOn == true {

            turnEditingModeOff()

        }
    }

    func getListOfCategoriesAndCheckToSeeIfTimerRunning(){

        categories = TrackingCategorySubclass.returnListOfCategories()
        logRecord = nil

        // if the app exits and is reloaded, need to look to see if tracking
        // any categories by looking at the logRecord
        // there can only be one open logRecord at a time, so just
        // look to see if there is one without a checkout date

        let lastRecord = LogRecordSubclass.returnLastLog() as NSArray
        if lastRecord.count > 0 {

            logRecord = lastRecord.objectAtIndex(0) as? LogRecord
            selectedCategory = logRecord!.logRecordsCategory as TrackingCategory
            self.navigationItem.rightBarButtonItem?.enabled = true
            stopButton.alpha = 1.0

        } else {

            stopButton.alpha = defaultAlpha
        }

    }


    // MARK: BUTTONS

    @IBAction func onStopButtonPressed(sender: AnyObject) {

        stopTimer()
        collectionV.reloadData()  // need to update display

    }


    @IBAction func onNewCategoryButtonPressed(sender: AnyObject) {

        addCategoryPart1_startByAskingUserForTitle()

    }

    @IBAction func onEditButtonPressed(sender: AnyObject) {

        toggleEditingMode()

    }


    // MARK: BUTTONS ON CELL (HANDLED HERE)

    @IBAction func onDeleteButtonPressed(sender: UIButton) {

        // when created cell, set the button's tag to the row number so we can know the row number we are working with
        let trackingC = categories?.objectAtIndex(sender.tag) as TrackingCategory
        deleteCategory(trackingC)

        // reload any active cells
        reloadData()

    }

    @IBAction func onLogButtonPressed(sender: TimerCollectionViewCell) {


        let dataObject = categories?.objectAtIndex(sender.tag) as TrackingCategory

        performSegueWithIdentifier("toDetail", sender: dataObject)

    }

    @IBAction func onDidEndOnExit(sender: UITextField) {

        sender.resignFirstResponder()
    }


    // MARK: START & STOP TIMERS

    func startTimer(forCategory:TrackingCategory){

        selectedCategory = forCategory
        self.navigationItem.rightBarButtonItem?.enabled = true

        // create new logRecord for category
        // (here, we are really just keeping start and stop time)
        let date = NSDate()
        logRecord = LogRecordSubclass.addNewLogRecord(checkinTime: date, parentCategory: forCategory)

        // start clock / counter
        // (the clock is just a scrolling counter)
        elapsedTimeForSelectedCategory = 0

        // remove alpha on stop button
        stopButton.alpha = 1.0

    }

    func stopTimer(){

        if logRecord != nil {

            LogRecordSubclass.updateLastLogUponCheckout(record: logRecord!)

        }

        // clear old values
        selectedCategory = nil
        logRecord = nil

        // add alpha to stop button
        stopButton.alpha = defaultAlpha

    }

    func clockTick(){

        elapsedTimeForSelectedCategory = elapsedTimeForSelectedCategory + clockTickEveryXSeconds

        if clockLabelToUpdate == nil { return; }

        // check to make sure the cell you are updating corresponds to the correct category (ie, they have the same index path)
        if clockLabelToUpdate?.tag == correctClockLabelTagNumber {

                clockLabelToUpdate?.attributedText = formatText(formatTime(elapsedTimeForSelectedCategory))

        }
        
    }

    func formatTime(elapsedTime:Double)->(String){


        // CALC HOURS, MIN, SEC, HUNDRETHS (just did it by hand, alternatively could have used function)

        // number of hours = time in sec (1 hour / 60 min)(1 min / 60 sec) with no remainder
        let hours = Int(elapsedTimeForSelectedCategory / 3600)

        // min
        // 1) the number of min is what is left over after we have taken the hours out - use mod 3600
        // 2) number of min = time in sec (1 min / 60 sec) with no remainder
        let min = Int((elapsedTimeForSelectedCategory % 3600)/60)

        // sec - whatever is left, after you remove the hours and min
        let sec = Int(elapsedTimeForSelectedCategory % 60)

        // hundreths - get two dec places, I just multiplied by 100 and used Int to get rid of dec
        let hundreths = Int(elapsedTimeForSelectedCategory*100)-Int(elapsedTimeForSelectedCategory)*100


        // PUT IN LEADING ZEROES
        var hundrethsAsString = ""

        if hundreths == 0 {

            hundrethsAsString = String(stringLiteral: "00")

        }else if hundreths < 10 {

            hundrethsAsString = String(stringLiteral: "0\(hundreths)")

        }else{

            hundrethsAsString = String(stringLiteral: "\(hundreths)")
        }


        // BUILD STRING
        return String(stringLiteral: "\(hours):\(min):\(sec):\(hundrethsAsString)")

    }


    // MARK: EDITING MODE

    func toggleEditingMode(){


        editingModeIsOn = !editingModeIsOn

        if editingModeIsOn == true {

            switchToEditingModeAndReload()

        } else {

            saveTitlesIfEdited()
            turnEditingModeOff()

        }

    }

    func switchToEditingModeAndReload(){

        self.navigationItem.rightBarButtonItem?.title = "Done"
        self.navigationItem.title = "Editing"

        collectionV.backgroundColor = UIColor(red: 229.0/255, green: 204.0/255, blue: 255.0/255, alpha: 0.8)

        // set tint color
        let window = UIApplication.sharedApplication().delegate?.window!
        window?.tintColor = UIColor.orangeColor()

        collectionV.reloadData()

    }

    func turnEditingModeOff(){

        editingModeIsOn = false // if not already done
        self.navigationItem.rightBarButtonItem?.title = "Edit"
        self.navigationItem.title = "Timers"

        collectionV.backgroundColor = UIColor.grayColor()

        // set tint color
        let window = UIApplication.sharedApplication().delegate?.window!
        window?.tintColor = UIColor.blueColor()

        reloadData()
        
    }


    // MARK: CRUD

    func deleteCategory(category:TrackingCategory){

        TrackingCategorySubclass.delTrackingCategory(obj: category)
        categories = TrackingCategorySubclass.returnListOfCategories()

        collectionV.reloadData()

    }

    func addCategoryPart1_startByAskingUserForTitle(){

        MCAlertWithTextEntry.presentAlertWithTextEntry_alertViewTitle("Add new category", forViewController: self) { (userEnteredText) -> Void in

            self.addCategoryPart2_thenAskForColor(userEnteredText)

        }
    }

    func addCategoryPart2_thenAskForColor(title:NSString){

        let alert = UIAlertController(title: "Select Color", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)

        var counter = 0

        // add a line in action sheet for each color
        for color in colors! {

            let colorToAdd = color as UIColor
            let action = UIAlertAction(title: colorNames?.objectAtIndex(counter) as NSString, style: UIAlertActionStyle.Default, handler: { (uiAlertAction) -> Void in


                self.addCategoryPart3_createNewCategory(title: title, color: colorToAdd)
            })

            alert.addAction(action)
            counter++
        }

        presentViewController(alert, animated: true) { () -> Void in }

    }

    func addCategoryPart3_createNewCategory(#title:NSString, color:UIColor){

        let ourTitle = title ?? ""
        TrackingCategorySubclass.addNewTrackingCategory(title:ourTitle, totalValue: 0, color: color)
        categories = TrackingCategorySubclass.returnListOfCategories()
        collectionV.reloadData()
        
    }

    func saveTitlesIfEdited(){

        if categories == nil { return; }

        var counter = 0

        for cat in categories! {

            // if category.title is different from the cell.title, update and save to db
            let theCat = cat as TrackingCategory
            let theCell = collectionV.cellForItemAtIndexPath(NSIndexPath(forItem: counter, inSection: 0)) as TimerCollectionViewCell

            if theCat.title != theCell.textLabel.text {

                // save title
                theCat.title = theCell.textLabel.text

                var err = NSErrorPointer()
                TrackingCategorySubclass.getMOC().save(err)

            }

            counter++
        }

    }


    // MARK: COLLECTION VIEW DATA SOURCE

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {

        return 1

    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if categories == nil {return 0;}

        return categories!.count

    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {


        // get cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("aaa", forIndexPath: indexPath) as TimerCollectionViewCell
        cell.layer.cornerRadius = 20;
        cell.layer.masksToBounds = true;

        // update content
        updateCell(cell: cell, indexPath:indexPath)
        ifSelectedCategoryFormatAndSetupClockCounter(cell: cell, indexPath: indexPath)
        turnFeaturesOnOrOffIfInEditingModeOrNot(cell: cell, indexPath: indexPath)


        return cell
        
    }

    func updateCell(#cell:TimerCollectionViewCell, indexPath:NSIndexPath){

        // get corresponding data object
        let dataObject = categories?.objectAtIndex(indexPath.row) as TrackingCategory

        let defaultText_elapsedTime = "0:00:00"

        // format text
        let formattedTitle = TextFormatter.createAttributedString(dataObject.title.uppercaseString, withFont: "Futura", fontSize: 14.0, fontColor: UIColor.greenColor(), nsTextAlignmentStyle: NSTextAlignment.Center) as NSAttributedString

        // set
        cell.storageView.backgroundColor = dataObject.color as? UIColor
        cell.storageView.alpha = defaultAlpha
        cell.textLabel.attributedText = formattedTitle
        cell.textLabel.backgroundColor = UIColor.clearColor()
        cell.layoutIfNeeded()

        cell.elapsedTime.attributedText = formatText(defaultText_elapsedTime)
        cell.elapsedTime.tag = -1

        //TextFormatter.printListOfFontFamilyNames()

    }

    func formatText(text:String)->(NSAttributedString){

        return TextFormatter.createAttributedString(text, withFont: "Damascus", fontSize: 28.0, fontColor: UIColor.greenColor(), nsTextAlignmentStyle: NSTextAlignment.Center) as NSAttributedString

    }

    func ifSelectedCategoryFormatAndSetupClockCounter(#cell:TimerCollectionViewCell, indexPath:NSIndexPath){

        // get corresponding data object
        let dataObject = categories?.objectAtIndex(indexPath.row) as TrackingCategory

        // if not select, exit
        if dataObject != selectedCategory {

            return;

        }

        // set default settings
        cell.storageView.alpha = 1.0
        
        // setup clock
        // - we will keep track of which view we are updating
        // - then we can tell it to update
        // - just need to check to see that the cell isn't being reused for a different row number
        clockLabelToUpdate = cell.elapsedTime  // our label / bad name

        correctClockLabelTagNumber = indexPath.row
        cell.elapsedTime.tag = indexPath.row

    }

    func turnFeaturesOnOrOffIfInEditingModeOrNot(#cell:TimerCollectionViewCell, indexPath:NSIndexPath){

        if editingModeIsOn == true {

            cell.textLabel.userInteractionEnabled = true
            cell.textLabel.textColor = UIColor.whiteColor()

            cell.viewLogLabel.hidden = false
            cell.deleteButton.hidden = false

            cell.deleteButton.tag = indexPath.row  // save row so can look up cell later

        } else {

            cell.textLabel.userInteractionEnabled = false
            cell.textLabel.textColor = UIColor.greenColor()

            cell.viewLogLabel.hidden = true
            cell.deleteButton.hidden = true

        }

    }


    // MARK: COLLECTION VIEW DELEGATE

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        let dataObject = categories?.objectAtIndex(indexPath.row) as TrackingCategory

        if editingModeIsOn == true {

            // do nothing

        } else {

            // if selected new category, stop old timer, start new timer
            if selectedCategory != dataObject {

                stopTimer()
                startTimer(dataObject)
                collectionV.reloadData()

            }

        }

    }


    // MARK: PREPARE SEGUE
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        let timerBeingEdited = sender as TrackingCategory

        var vc = segue.destinationViewController as LogViewController
        vc.selectedTimer = timerBeingEdited

    }

}
