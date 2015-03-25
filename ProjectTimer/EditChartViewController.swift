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


        @IBOutlet weak var viewToInsertChartAndLegendInto: UIView!
        @IBOutlet weak var view_noTimersToView: UIView!

        @IBOutlet weak var textField_chartName: UITextField!
        @IBAction func chartTextField_textEntryCompleted(sender: AnyObject) {}


    
    // xxxxxxxxxxx
    // our superclass will display the Legend and Chart
    // xxxxxxxxxxx


    // MARK: PREPARE TO DISPLAY DATA

    override func
        getThePieChartCategoriesYouWantToDisplay_OverrideHereIfSubclassing() -> (NSSet) {

        importNewTimerCategoriesIntoChart()
        let itemsForDisplay = pieChartBeingEdited!.pieChartsCategoryWrappers

        return itemsForDisplay

            // 1) these are category wrapper items, which will be converted into pie chart DataItems by the superclass 
            // 2) we will edit these DataItems in willCreateChartAndGraph, below
        
    }

    override func getTheViewToInsertTheChartAndLegendInto() -> (UIView?) {

        viewToInsertChartAndLegendInto.alpha = 0.7
        return viewToInsertChartAndLegendInto

    }

    override func willCreateChartAndGraph(#arrayOfDataItemsToDisplay:[DataItem]!) {

        // do not display both legend and chart vertically
        splitViewBetweenChartAndLegend = false


        // ADD CHECKMARKS

        // a DataItem has a property isSelected which will determine
        // whether or not it is given a checkmark in the table view

        // but, in this case, we want our checkmarks to correspond to the
        //  notUsedInChart property on our original data item
        // (rem: this VC, allows us to select which elements show in our final pie chart)

        for item in arrayOfDataItemsToDisplay {

            let parentObject:PieChartCategoryWrapper = item.pointerToParentObject as PieChartCategoryWrapper

            let shouldNotCheckMark = parentObject.notUsedInChart as Bool
            let shouldCheckMark = !shouldNotCheckMark
            item.isSelected = shouldCheckMark

        }

    }

    override func didCreateChartAndGraph() {

        // set alpha so can see background pie chart 
        self.pieChartAndLegend?.table?.alpha = 0.7
    }

    override func itemWasSelected(#theObjectYouPassedIn: AnyObject?) {

        let categoryWrapperObj = theObjectYouPassedIn as PieChartCategoryWrapper

        // !!! need to refetch object (for some reason, it is not live) !!!
        var err = NSErrorPointer()
        let catWrapper = PieChartCategoryWrapperSubclass.getMOC().existingObjectWithID(categoryWrapperObj.objectID, error: err) as PieChartCategoryWrapper

        // toggle notUsedInChart value
        // (this will just change our check mark here, but in the stats controller it means it will not be included)
        let usedInChart = catWrapper.notUsedInChart as Bool
        catWrapper.notUsedInChart = !usedInChart
        catWrapper.position = 99

        // save updates
        let didSave = PieChartCategoryWrapperSubclass.getMOC().save(err)
        if err != nil || didSave == false { println("error: \(err)")}

                let catWrapper2 = PieChartCategoryWrapperSubclass.getMOC().existingObjectWithID(categoryWrapperObj.objectID, error: err) as PieChartCategoryWrapper
        println(catWrapper2)

    }

    override func colorWasChangedForItem(#theObjectYouPassedIn: AnyObject?, color: UIColor) {

        // override if desired

    }

    // MARK: UPDATE LIST OF CATEGORIES

    func importNewTimerCategoriesIntoChart(){

        // get recently added categories
        let arrayOfNewCategories = createListOfNewTimerCategoriesCanAddToPieChart()

        // put each in a wrapper and add to your chart
        var indexOfNewCat = Double(pieChartBeingEdited!.pieChartsCategoryWrappers.count)

        for cat in arrayOfNewCategories {

            let wrapper = PieChartCategoryWrapperSubclass.createCategoryWrapperForPieChart(pieChart: pieChartBeingEdited!, baseCategory: cat as TrackingCategory, positionIndexNumber: indexOfNewCat)

            indexOfNewCat++

        }

    }

    func createListOfNewTimerCategoriesCanAddToPieChart()->(NSArray){

        // get list of all your old categories (stored inside their wrappers)

        var oldCategories = NSSet()

        if pieChartBeingEdited?.pieChartsCategoryWrappers != nil {

            oldCategories = pieChartBeingEdited!.pieChartsCategoryWrappers

        }


        var arrayOfCategories = NSMutableArray()

        for wrapper in oldCategories {

            arrayOfCategories.addObject(wrapper.catWrappersBaseCategory)
        }

        // get list of all of the timers categories
        let allTrackingCategories = TrackingCategorySubclass.returnListOfCategories()

        // create list of category that the pie chart doesn't have yet
        var arrayOfNewCategories = NSMutableArray()

        for trackingCategory in allTrackingCategories {

            let ourTrackingCategory = trackingCategory as TrackingCategory
            var isNewCat = true

            for categoriesAlreadyHave in arrayOfCategories {

                let ourCategoriesAlreadyHave = categoriesAlreadyHave as? TrackingCategory

                if ourTrackingCategory == ourCategoriesAlreadyHave {

                    isNewCat = false
                    break
                    
                }
                
            }
            
            if isNewCat == true {
                
                arrayOfNewCategories.addObject(trackingCategory)
                
            }
        }
        
        return arrayOfNewCategories
        
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


    // MARK: LIFECYCLE

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // set tint color
        let window = UIApplication.sharedApplication().delegate?.window!
        window?.tintColor = UIColor.orangeColor()

        // update label
        if pieChartBeingEdited?.chartTitle != nil {

            let theTitle = pieChartBeingEdited!.chartTitle as String
            textField_chartName.attributedText = TextFormatter.createAttributedString(theTitle, withFont: "Papyrus", fontSize: 28, fontColor: UIColor.blackColor(), nsTextAlignmentStyle: NSTextAlignment.Center)


        }

        // hide unwanted views
        view_noTimersToView.hidden = true

        // present instructions in alert
        let alert = UIAlertController(title: "Edit Pie Graph", message: "Select which timers you would like to include in your PieChart.", preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler:nil)
        alert.addAction(action)
        self.presentViewController(alert, animated: false) { () -> Void in }

    }

    override func viewWillDisappear(animated: Bool) {

        // set tint color
        let window = UIApplication.sharedApplication().delegate?.window!
        window?.tintColor = UIColor.blueColor()

        // save edited chart
        pieChartBeingEdited?.chartTitle = textField_chartName.text

    }



}
