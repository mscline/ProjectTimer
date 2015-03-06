//
//  ViewController.swift
//  PieChart
//
//  Created by xcode on 1/21/15.
//  Copyright (c) 2015 MSCline. All rights reserved.
//


import UIKit

class ChartAndLegendVC_Superclass: UIViewController, MCTable_DataItemProtocol {


        // instance variables
        var setOfCategoriesToDisplay_yourRawData:NSSet?
        var arrayOfDataToDisplay:[DataItem] = Array()

        var pieChartAndLegend:PieChartAndLegend?
        var colors:NSArray?


    // xxxxxxxxxxxxxxxxxxxxxxx
    // METHODS TO OVERRIDE IF SUBCLASSING
    // xxxxxxxxxxxxxxxxxxxxxxx

    func getThePieChartCategoriesYouWantToDisplay_OverrideHereIfSubclassing() -> (NSSet) {

        // get the selected pie chart and grab its categories

        let selectedPieChart = PieChartThumbnailSubclass.getTheSelectedPieChart()
        let categories = selectedPieChart!.chartsCategories as NSSet
// fix = should let go to vc if no pie chart created?  or put alt image??
        return categories

    }

    func willCreateChartAndGraph(#arrayOfDataItemsToDisplay:[DataItem]!){

        // last chance to make any changes (eg, change dataItem.isSelected = true)

    }

    // xxxxxxxxxxxxxxxxxxxxxxx
    // xxxxxxxxxxxxxxxxxxxxxxx


    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)


        // build the chart and legend

        setOfCategoriesToDisplay_yourRawData = self.getThePieChartCategoriesYouWantToDisplay_OverrideHereIfSubclassing()  // this is just a bridge / broken out section, so can subclass it

        buildData()

        if arrayOfDataToDisplay.count > 0 {

            self.willCreateChartAndGraph(arrayOfDataItemsToDisplay: arrayOfDataToDisplay)  // added so if subclassing, you can override and add code
            pieChartAndLegend = PieChartAndLegend(arrayOfPieDataObjects: arrayOfDataToDisplay, forView: self.view)

        }

    }

    func buildData(){

        // remove old data
        arrayOfDataToDisplay.removeAll(keepCapacity: true)

        // get the categories from the pie chart object and iterate thru
        for category in setOfCategoriesToDisplay_yourRawData! {

            // find elapsedTime
            let cat = category as TrackingCategory
            let sum = TrackingCategorySubclass.sumTotalOfLogRecords(parentCategory: cat)
            let elapsedT = sum ?? 0

            cat.totalValue = NSInteger(elapsedT)

            // update db
            var err = NSErrorPointer()
            TrackingCategorySubclass.getMOC().save(err)

            // create data item to pass to pie chart and label class
            let item = DataItem(title:      cat.title,
                                color:      cat.color as? UIColor,
                                amount:     Int(cat.totalValue),
                                isSelected: true,
                                optional_parentObject: cat)

            arrayOfDataToDisplay.append(item)

        }

    }

    
    // MARK: CODING

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    // MARK: ROTATIONS

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {

        pieChartAndLegend!.setScreenElementPositions(forViewWithSize: size)

    }


}




