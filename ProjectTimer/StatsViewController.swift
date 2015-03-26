//
//  StatsViewController.swift
//  ProjectTimer
//
//  Created by xcode on 3/5/15.
//  Copyright (c) 2015 MSCline. All rights reserved.
//

import UIKit

class StatsViewController: ChartAndLegendVC_Superclass {


        var selectedPieChart:PieChartThumbnail?

        @IBOutlet weak var defaultViewToShowIfNoData: UIView!


    override func viewWillAppear(animated: Bool) {

        defaultViewToShowIfNoData.hidden = true
        self.navigationItem.title = selectedPieChart?.chartTitle ?? "Statistics"

        super.viewWillAppear(animated)

    }

    override func getThePieChartCategoriesYouWantToDisplay_OverrideHereIfSubclassing() -> (NSSet) {

        // get the selected pie chart and grab its categories
        selectedPieChart = PieChartThumbnailSubclass.getTheSelectedPieChart()

        // this gives us a list of the charts categories for free
        if selectedPieChart == nil || selectedPieChart!.pieChartsCategoryWrappers == nil { return NSSet()}
        var listOfAllCatWrappers = selectedPieChart!.pieChartsCategoryWrappers as NSSet

        // unfortunately, we do not have a filtered list - we do not want to display the hidden cats
        // we have two options: a) requery the db  b) just filter it with a nested loop => we will do that

        // make list of items that are not hidden
        var itemsForDisplay = NSMutableSet()

        for item in listOfAllCatWrappers {

            let ourItem = item as PieChartCategoryWrapper
            if ourItem.notUsedInChart == false {

                itemsForDisplay.addObject(ourItem)

            }
        }

        return itemsForDisplay
        
    }

// DELETE
//    override func itemWasSelected(#theObjectYouPassedIn: AnyObject?) {
//
//        let categoryWrapperObj = theObjectYouPassedIn as PieChartCategoryWrapper
//
//        // !!! need to refetch object (for some reason, it is not live) !!!
//        var err = NSErrorPointer()
//        let catWrapper = PieChartCategoryWrapperSubclass.getMOC().existingObjectWithID(categoryWrapperObj.objectID, error: err) as PieChartCategoryWrapper
//
//        // toggle isSelected value
//        // (this will just change our check mark here, but in the stats controller it means it will not be included)
//        let shouldBeSelected = catWrapper.isSelected as Bool
//        catWrapper.isSelected = !shouldBeSelected
//
//        // save updates
//        let didSave = PieChartCategoryWrapperSubclass.getMOC().save(err)
//        if err != nil || didSave == false { println("error: \(err)")}
//
//        let catWrapper2 = PieChartCategoryWrapperSubclass.getMOC().existingObjectWithID(categoryWrapperObj.objectID, error: err) as PieChartCategoryWrapper
//        println(catWrapper2)
//        
//    }

    
    override func noDataToDispalyInChart(){

        // if no data to display, can customize view here
        defaultViewToShowIfNoData.hidden = false

        // remove old pieChart and legend if necessary
        pieChartAndLegend?.pieChart?.removeFromSuperview()
        pieChartAndLegend?.table?.removeFromSuperview()

        if pieChartAndLegend?.pieChart != nil {

            pieChartAndLegend?.pieChart = nil
            pieChartAndLegend?.table = nil

        }

    }

    override func viewWillDisappear(animated: Bool) {

        // save thumb of chart
        if selectedPieChart != nil {

            addSnapShotOfChartToPieChartThumbObject(selectedPieChart!)

            var err = NSErrorPointer()
            PieChartThumbnailSubclass.getMOC().save(err)

        }

        // call superclass viewWillDisappear
        super.viewWillDisappear(animated)

    }

}
