//
//  TimerViewController.swift
//  PieChart
//
//  Created by xcode on 2/17/15.
//  Copyright (c) 2015 MSCline. All rights reserved.
//

import UIKit

class TimerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {


        // INSTANCE VARIABLES
        var selectedCategory:TrackingCategorySubclass?
        var logRecord:LogRecordSubclass?

        var categories:NSArray?
        var colors:NSArray?

        // OUTLETS
        @IBOutlet weak var collectionV: UICollectionView!

        // CONSTANTS
        let defaultAlpha:CGFloat = 0.6


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

        let lastRecord = LogRecordSubclass.returnLastLog()as NSArray
        if lastRecord.count > 0 {

            logRecord = lastRecord.objectAtIndex(0) as? LogRecordSubclass
            selectedCategory = logRecord?.logRecordsCategory as? TrackingCategorySubclass
        }
    }

    func startTimer(forCategory:TrackingCategorySubclass){

        selectedCategory = forCategory

        // create new logRecord for category
        let date = NSDate()
        logRecord = LogRecordSubclass.addNewLogRecord(checkinTime: date, parentCategory: forCategory)

    }

    func stopTimer(){

        // !? had originally setup as instance method, but won't run (doesn't like the subclassing?)

        if logRecord != nil {

            LogRecordSubclass.updateLastLogUponCheckout(record: logRecord!)

        }

        // clear old values
        selectedCategory = nil
        logRecord = nil

    }

    @IBAction func onStopButtonPressed(sender: AnyObject) {

        stopTimer()
        collectionV.reloadData()  // need to update display

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
        let dataObject = categories?.objectAtIndex(indexPath.row) as TrackingCategorySubclass

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

        let dataObject = categories?.objectAtIndex(indexPath.row) as TrackingCategorySubclass

        stopTimer()
        startTimer(dataObject)
        collectionV.reloadData()

    }

}
