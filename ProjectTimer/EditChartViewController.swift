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
        var showAlertMessageWhenReturnToThisScreen = true

        // subviews
        @IBOutlet weak var viewToInsertChartInto: UIView!
        @IBOutlet weak var viewToInsertLegendInto: UIView!
        @IBOutlet weak var view_noTimersToView: UIView!

        // constraints
        @IBOutlet weak var pieView_xValue: NSLayoutConstraint!
        @IBOutlet weak var pieView_yValue: NSLayoutConstraint!
        @IBOutlet weak var pieView_width: NSLayoutConstraint!
        @IBOutlet weak var pieView_height: NSLayoutConstraint!


    @IBOutlet weak var textField_chartName: UITextField!
        @IBAction func chartTextField_textEntryCompleted(sender: AnyObject) {}


    
    // xxxxxxxxxxx
    // our superclass will display the Legend and Chart
    // xxxxxxxxxxx


    // MARK: PREPARE TO DISPLAY DATA

    override func
        getThePieChartCategoriesYouWantToDisplay_OverrideHereIfSubclassing() -> (NSSet) {

        importNewTimerCategoriesIntoChart()
        if pieChartBeingEdited == nil {return NSSet();}
        let itemsForDisplay = pieChartBeingEdited!.pieChartsCategoryWrappers

        return itemsForDisplay

            // 1) these are category wrapper items, which will be converted into pie chart DataItems by the superclass 
            // 2) we will edit these DataItems in willCreateChartAndGraph, below
        
    }

    override func getTheViewToInsertTheChartInto() -> (UIView?) {

        // IF REFACTOR: prob move to layoutSubviews, it might be better there

        // the pie chart will be inserted into one of your views
        // adjust views to put chart and legend in, based on whether in portrait or landscape

        if self.view.frame.size.height > self.view.frame.size.width {

            pieView_xValue.constant = 0
            pieView_yValue.constant = 15
            pieView_width.constant  = 10 * self.view.frame.size.width
            pieView_height.constant = 1.3 * self.view.frame.size.height

            // Apple won't resize immediately, even if call layoutSubviews, so set frame value so that the correct values are passed in when make legend and chart

            // set frames to same values as constraints
            viewToInsertChartInto.frame = CGRectMake(pieView_xValue.constant, pieView_yValue.constant, pieView_width.constant, pieView_height.constant)

        }else{

            pieView_xValue.constant = 0
            pieView_yValue.constant = -0.2 * self.view.frame.size.height
            pieView_width.constant  = 10 * self.view.frame.size.width
            pieView_height.constant = 4 * self.view.frame.size.height

            // set frames to same values as constraints
            viewToInsertChartInto.frame = CGRectMake(pieView_xValue.constant, pieView_yValue.constant, pieView_width.constant, pieView_height.constant)

        }

        return viewToInsertChartInto

    }

    override func layoutChartAndLegendInSeparateViews_viewNumberTwoForLegend() -> (UIView?) {

        return viewToInsertLegendInto
    }

    override func willCreateChartAndGraph(arrayOfDataItemsToDisplay arrayOfDataItemsToDisplay:[DataItem]!) {

        // do not display both legend and chart vertically
        splitViewBetweenChartAndLegend = false


        // ADD CHECKMARKS

        // a DataItem has a property isSelected which will determine
        // whether or not it is given a checkmark in the table view

        // but, in this case, we want our checkmarks to correspond to the
        //  notUsedInChart property on our original data item
        // (rem: this VC, allows us to select which elements show in our final pie chart)

        for item in arrayOfDataItemsToDisplay {

            let parentObject:PieChartCategoryWrapper = item.pointerToParentObject as! PieChartCategoryWrapper

            let shouldNotCheckMark = parentObject.notUsedInChart as Bool
            let shouldCheckMark = !shouldNotCheckMark
            item.isSelected = shouldCheckMark

        }

    }

    override func didCreateChartAndGraph() {

        // set background color to clear and alpha to soften
        self.pieChartAndLegend?.table?.alpha = 0.8
        self.pieChartAndLegend?.table?.separatorColor = UIColor.clearColor()
        self.pieChartAndLegend?.table?.backgroundColor = UIColor.clearColor()

    }

    override func itemWasSelected(theObjectYouPassedIn theObjectYouPassedIn: AnyObject?) {

        let categoryWrapperObj = theObjectYouPassedIn as! PieChartCategoryWrapper

        // !!! need to refetch object (for some reason, it is not live, Apple treating it like it is concurrent?) !!!
        let err = NSErrorPointer()

        do {
            let catWrapper = try PieChartCategoryWrapperSubclass.getMOC().existingObjectWithID(categoryWrapperObj.objectID) as! PieChartCategoryWrapper

            // toggle notUsedInChart value
            // (this will just change our check mark here, but in the stats controller it means it will not be included)
            let usedInChart = catWrapper.notUsedInChart as Bool
            catWrapper.notUsedInChart = !usedInChart

        } catch let error as NSError {
            err.memory = error
        }

        // save updates
        let didSave: Bool
        do {
            try PieChartCategoryWrapperSubclass.getMOC().save()
            didSave = true
        } catch let error as NSError {
            err.memory = error
            didSave = false
        }
        if err != nil || didSave == false { print("error: \(err)")}

    }


    // MARK: UPDATE LIST OF CATEGORIES

    func importNewTimerCategoriesIntoChart(){

        // get recently added categories
        let arrayOfNewCategories = createListOfNewTimerCategoriesCanAddToPieChart()

        // put each in a wrapper and add to your chart
        if pieChartBeingEdited == nil { return; }
        var indexOfNewCat = Double(pieChartBeingEdited!.pieChartsCategoryWrappers.count)

        for cat in arrayOfNewCategories {

            PieChartCategoryWrapperSubclass.createCategoryWrapperForPieChart(pieChart: pieChartBeingEdited!, baseCategory: cat as! TrackingCategory, positionIndexNumber: indexOfNewCat)

            indexOfNewCat += 1

        }

    }

    func createListOfNewTimerCategoriesCanAddToPieChart()->(NSArray){

        // get list of all your old categories (stored inside their wrappers)

        var oldCategories = NSSet()

        if pieChartBeingEdited?.pieChartsCategoryWrappers != nil {

            oldCategories = pieChartBeingEdited!.pieChartsCategoryWrappers

        }


        let arrayOfCategories = NSMutableArray()

        for wrapper in oldCategories {

            arrayOfCategories.addObject(wrapper.catWrappersBaseCategory)
        }

        // get list of all of the timers categories
        let allTrackingCategories = TrackingCategorySubclass.returnListOfCategories()

        // create list of category that the pie chart doesn't have yet
        let arrayOfNewCategories = NSMutableArray()

        for trackingCategory in allTrackingCategories {

            let ourTrackingCategory = trackingCategory as! TrackingCategory
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
        pieChartBeingEdited = nil
        
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
            textField_chartName.attributedText = TextFormatter.createAttributedString(theTitle, withFont: "Papyrus", fontSize: 24, fontColor: UIColor.blackColor(), nsTextAlignmentStyle: NSTextAlignment.Left)


        }

        // hide unwanted views
        view_noTimersToView.hidden = true

        // if came from Pie Charts VC, then display alert

        if showAlertMessageWhenReturnToThisScreen == true {

            // don't show alert if this vc is on the top of its nav controller's stack
            showAlertMessageWhenReturnToThisScreen = false

            // present instructions in alert
            let alert = UIAlertController(title: "Edit Pie Graph", message: "Select which timers you would like to include in your PieChart.", preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler:nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: false) { () -> Void in }
            
        }

    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        // set tint color
        let window = UIApplication.sharedApplication().delegate?.window!
        window?.tintColor = UIColor.blueColor()

        pieChartBeingEdited?.chartTitle = textField_chartName.text

    }

}
