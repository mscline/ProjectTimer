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
        
    }

    override func getTheViewToInsertTheChartAndLegendInto() -> (UIView?) {

        viewToInsertChartAndLegendInto.alpha = 0.7
        return viewToInsertChartAndLegendInto

    }

    override func willCreateChartAndGraph(#arrayOfDataItemsToDisplay:[DataItem]!) {

        // do not display both legend and chart vertically
        splitViewBetweenChartAndLegend = false
        
        // deselect all items (just go with brute force)
        for item in arrayOfDataItemsToDisplay {

            item.isSelected = false

        }

        // if an item belongs to a category, it should be selected (go with brute force nested loop)
        for item in arrayOfDataItemsToDisplay {

            let parentObject:AnyObject? = item.pointerToParentObject
            if parentObject == nil { continue; }
            if pieChartBeingEdited!.pieChartsCategoryWrappers == nil { break; }

            for category in pieChartBeingEdited!.pieChartsCategoryWrappers {

                    if category === parentObject! {

                        item.isSelected = true

                    }
                
            }

        }

    }

    override func didCreateChartAndGraph() {

        // set alpha so can see background pie chart 
        self.pieChartAndLegend?.table?.alpha = 0.7
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
