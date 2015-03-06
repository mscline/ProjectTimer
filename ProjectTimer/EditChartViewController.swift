//
//  EditChartViewController.swift
//  ProjectTimer
//
//  Created by xcode on 3/5/15.
//  Copyright (c) 2015 MSCline. All rights reserved.
//

import UIKit

class EditChartViewController: ChartAndLegendVC_Superclass {  // nearly identical to ViewController (ie, display chart and graph), so just going to subclass


        var pieChartBeingEdited:PieChartThumbnail?
        var doNotSaveOnExit:Bool = false

    @IBOutlet weak var textField_chartName: UITextField!

    @IBAction func chartTextField_textEntryCompleted(sender: AnyObject) {
    }


    
    // xxxxxxxxxxx
    // SUPERCLASS will display Legend and Chart
    // xxxxxxxxxxx


    // PREPARE TO DISPLAY DATA

    override func getThePieChartCategoriesYouWantToDisplay_OverrideHereIfSubclassing() -> (NSSet) {

        let arrayOfDataToDisplay = TrackingCategorySubclass.returnListOfCategories()
        return NSSet(array: arrayOfDataToDisplay)
        
    }

    override func willCreateChartAndGraph(#arrayOfDataItemsToDisplay:[DataItem]!) {

        // deselect all items (just go with brute force)
        for item in arrayOfDataItemsToDisplay {

            item.isSelected = false

        }

        // if an item belongs to a category, it should be selected (go with brute force nested loop)
        for item in arrayOfDataItemsToDisplay {

            let parentObject:AnyObject? = item.pointerToParentObject
            if parentObject == nil { continue; }

            for category in pieChartBeingEdited!.chartsCategories {

                    if category === parentObject! {

                        item.isSelected = true

                    }
                
            }

        }
    }


    // MARK: DELETE CHART

    @IBAction func onDeleteButtonPressed(sender: AnyObject) {

        confirmDeletion()

    }

    func confirmDeletion(){

        let alert = UIAlertController(title: "Confirmation Required", message: "Are you sure you want to delete your chart?", preferredStyle: UIAlertControllerStyle.Alert)

        let action = UIAlertAction(title: "DELETE", style: UIAlertActionStyle.Default, handler: { (uiAlertAction) -> Void in

            self.deleteChart()

        })

        let action2 = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (uiAlertAction) -> Void in })

        alert.addAction(action)
        alert.addAction(action2)
        presentViewController(alert, animated: true) { () -> Void in }

    }

    func deleteChart(){

        PieChartThumbnailSubclass.deletePieChart(pieChartBeingEdited!)
        doNotSaveOnExit = true

        self.navigationController?.popToRootViewControllerAnimated(true)

    }


    // MARK: SAVE DATA ON EXIT

    func saveSelectedCategoriesForChart(){

        if doNotSaveOnExit == true { return; }

        let selectedItems = getSelectedDataObjectsFromPieChartAndLegend()
        addSelectedElementsToPieChart(arrayOfSelectedItems: selectedItems)
        saveSnapShotOfChartInPieChartThumbObject()

    }

    func getSelectedDataObjectsFromPieChartAndLegend()->(Array<DataItem>){

        // make arrays to store selected items in
        var selectedItems:[DataItem] = Array()
        var selectedLegendItems:[MCTableDataObject] = Array()

        // the legend uses the dataItem we give it to create a legendDataItem
        let arrayOfLegendObjects = self.pieChartAndLegend!.arrayOfLegendItems


        // add selected items to our array of legend items
        for item in arrayOfLegendObjects {

            let ourItem = item as MCTableDataObject

            if ourItem.isSelected == true {

                selectedLegendItems.append(ourItem)
            }

        }

        // each legend item, knows who its parent is
        // for each selected item, add parentDataObjects / our dataItems to an array
        for item in selectedLegendItems {

            let ourItem = item as MCTableDataObject
            let parentObj:DataItem = item.wrappedObject as DataItem
            selectedItems.append(parentObj)

        }

        return selectedItems
    }

    func addSelectedElementsToPieChart(#arrayOfSelectedItems:Array<DataItem>){

        for item in arrayOfSelectedItems {

            let ourItem = item as DataItem
            let trackingCategory:AnyObject? = ourItem.pointerToParentObject

            if trackingCategory != nil {

                pieChartBeingEdited?.addChartsCategoriesObject(trackingCategory as TrackingCategory)

            }

        }

    }

    func saveSnapShotOfChartInPieChartThumbObject(){

        let viewWorkingWith = self.pieChartAndLegend!.pieChart!
        UIGraphicsBeginImageContext(viewWorkingWith.frame.size)
        viewWorkingWith.layer.renderInContext(UIGraphicsGetCurrentContext())
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        pieChartBeingEdited?.snapshot = image

    }

    // MARK: LIFECYCLE

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // set tint color
        let window = UIApplication.sharedApplication().delegate?.window!
        window?.tintColor = UIColor.orangeColor()

        // update label
        if pieChartBeingEdited?.chartTitle != nil {

            textField_chartName.text = pieChartBeingEdited?.chartTitle

        }

    }

    override func viewWillDisappear(animated: Bool) {

        // set tint color
        let window = UIApplication.sharedApplication().delegate?.window!
        window?.tintColor = UIColor.blueColor()

        // save edited chart
        saveSelectedCategoriesForChart()
        pieChartBeingEdited?.chartTitle = textField_chartName.text
        
    }



}
