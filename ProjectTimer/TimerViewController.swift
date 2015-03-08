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

        // EDITING MODE
        var editingModeIsOn = false

        // OUTLETS
        @IBOutlet weak var collectionV: UICollectionView!

        // CONSTANTS
        let defaultAlpha:CGFloat = 0.6


    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        getListOfCategoriesAndCheckToSeeIfTimerRunning()
        collectionV.reloadData()

    }


    func getListOfCategoriesAndCheckToSeeIfTimerRunning(){

        categories = TrackingCategorySubclass.returnListOfCategories()

        // if the app exits and is reloaded, need to look to see if tracking
        // any categories by looking at the logRecord
        // there can only be one open logRecord at a time, so just
        // look to see if there is one without a checkout date

        let lastRecord = LogRecordSubclass.returnLastLog() as NSArray
        if lastRecord.count > 0 {

            logRecord = lastRecord.objectAtIndex(0) as? LogRecord
            selectedCategory = logRecord!.logRecordsCategory as TrackingCategory
            self.navigationItem.rightBarButtonItem?.enabled = true

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

    @IBAction func onDeleteButtonPressed(sender: UIButton) {

        // when created cell, set the button's tag to the row number so we can know the row number we are working with
        let trackingC = categories?.objectAtIndex(sender.tag) as TrackingCategory
        deleteCategory(trackingC)

    }


    // MARK: Start & Stop Timers

    func startTimer(forCategory:TrackingCategory){

        selectedCategory = forCategory
        self.navigationItem.rightBarButtonItem?.enabled = true

        // create new logRecord for category
        let date = NSDate()
        logRecord = LogRecordSubclass.addNewLogRecord(checkinTime: date, parentCategory: forCategory)

    }

    func stopTimer(){

        if logRecord != nil {

            LogRecordSubclass.updateLastLogUponCheckout(record: logRecord!)

        }

        // clear old values
        selectedCategory = nil
        logRecord = nil
        
    }


    // MARK: EDITING MODE

    func toggleEditingMode(){


        editingModeIsOn = !editingModeIsOn

        if editingModeIsOn == true {

            switchToEditingModeAndReload()

        } else {

            turnEditingModeOff()
            
        }

    }

    func switchToEditingModeAndReload(){

        collectionV.backgroundColor = UIColor.lightGrayColor()
        collectionV.alpha = 0.7

       // self.navigationItem.rightBarButtonItem.set

        collectionV.reloadData()

    }

    func turnEditingModeOff(){

        collectionV.backgroundColor = UIColor.blackColor()
        collectionV.alpha = 1.0

        collectionV.reloadData()

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


    // MARK: COLLECTION VIEW DATA SOURCE

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {

        return 1

    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if categories == nil {return 0;}

        return categories!.count

    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("aaa", forIndexPath: indexPath) as TimerCollectionViewCell

        updateCell(cell: cell, indexPath:indexPath)
        turnFeaturesOnOrOffIfInEditingModeOrNot(cell: cell, indexPath: indexPath)

        return cell
        
    }

    func updateCell(#cell:TimerCollectionViewCell, indexPath:NSIndexPath){

        // get corresponding data object
        let dataObject = categories?.objectAtIndex(indexPath.row) as TrackingCategory

        cell.backgroundColor = dataObject.color as? UIColor
        cell.alpha = defaultAlpha
        cell.textLabel.text = dataObject.title
        cell.textLabel.backgroundColor = UIColor.clearColor()

        if dataObject == selectedCategory {

            cell.alpha = 1.0
        }

    }

    func turnFeaturesOnOrOffIfInEditingModeOrNot(#cell:TimerCollectionViewCell, indexPath:NSIndexPath){

        if editingModeIsOn == true {

            cell.textLabel.userInteractionEnabled = true
            cell.textLabel.backgroundColor = UIColor.grayColor()

            cell.viewLogLabel.hidden = false
            cell.deleteButton.hidden = false

            cell.deleteButton.tag = indexPath.row  // save row so can look up cell later

        } else {

            cell.textLabel.userInteractionEnabled = false
            cell.textLabel.backgroundColor = UIColor.clearColor()

            cell.viewLogLabel.hidden = true
            cell.deleteButton.hidden = true

        }

    }

    // MARK: COLLECTION VIEW DELEGATE

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        let dataObject = categories?.objectAtIndex(indexPath.row) as TrackingCategory

        if editingModeIsOn == true {

            performSegueWithIdentifier("toDetail", sender: dataObject)

        } else {

            stopTimer()
            startTimer(dataObject)
            collectionV.reloadData()

        }

    }


    // MARK: PREPARE SEGUE
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        let timerBeingEdited = sender as TrackingCategory

        var vc = segue.destinationViewController as LogViewController
        vc.selectedTimer = timerBeingEdited

    }

}
