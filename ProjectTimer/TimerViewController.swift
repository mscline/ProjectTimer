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



        // OUTLETS
        @IBOutlet weak var collectionV: UICollectionView!

        // CONSTANTS
        let defaultAlpha:CGFloat = 0.6


    override func viewDidLoad() {
        super.viewDidLoad()

        getListOfCategoriesAndCheckToSeeIfTimerRunning()
        collectionV.reloadData()
        self.navigationItem.rightBarButtonItem?.enabled = false

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

        // disable button to see detail
        self.navigationItem.rightBarButtonItem?.enabled = false

    }


    // MARK: BUTTONS

    @IBAction func onStopButtonPressed(sender: AnyObject) {

        stopTimer()
        collectionV.reloadData()  // need to update display

    }


    @IBAction func onNewCategoryButtonPressed(sender: AnyObject) {

        addCategoryPart1_startByAskingUserForTitle()

    }



    @IBAction func onDeleteButtonPressed(sender: AnyObject) {
    }


    // MARK: CRUD

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


    // MARK: COLLECTION VIEW DELEGATE

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        let dataObject = categories?.objectAtIndex(indexPath.row) as TrackingCategory

        stopTimer()
        startTimer(dataObject)
        collectionV.reloadData()

    }


    // MARK: PREPARE SEGUE
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        var vc = segue.destinationViewController as LogViewController
        vc.selectedTimer = selectedCategory!

    }

}
