//
//  ViewController.swift
//  PieChart
//
//  Created by xcode on 1/21/15.
//  Copyright (c) 2015 MSCline. All rights reserved.
//


import UIKit

class ChartAndLegendVC_Superclass: UIViewController, MCTable_DataItemProtocol {


        // instance variables (you can access them, but override methods to provide required data)
        var setOfCategoriesToDisplay_yourRawData:NSSet?
        var arrayOfDataToDisplay:[DataItem] = Array()
        var insertIntoView:UIView?

        var pieChartAndLegend:PieChartAndLegend?
        var colors:NSArray?


    // xxxxxxxxxxxxxxxxxxxxxxx
    // MARK: METHODS TO OVERRIDE IF SUBCLASSING
    // xxxxxxxxxxxxxxxxxxxxxxx

    func getThePieChartCategoriesYouWantToDisplay_OverrideHereIfSubclassing() -> (NSSet) {

        return NSSet()

    }

    func getTheViewToInsertTheChartAndLegendInto()->(UIView?){

        return nil
    }

    func willCreateChartAndGraph(#arrayOfDataItemsToDisplay:[DataItem]!){

        // last chance to make any changes (eg, change dataItem.isSelected = true)

    }

    func noDataToDispalyInChart(){

        // if no data to display, can customize view here

    }
    

    // xxxxxxxxxxxxxxxxxxxxxxx
    // xxxxxxxxxxxxxxxxxxxxxxx


    // MARK: LIFECYCLE

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        buildChartAndLegend()

    }

    // MARK: ROTATIONS
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {

        buildChartAndLegend()
        
    }


    // MARK: BUILD IT
    func buildChartAndLegend(){

        // get data from user and process
        setOfCategoriesToDisplay_yourRawData = self.getThePieChartCategoriesYouWantToDisplay_OverrideHereIfSubclassing()

        buildData()

        if arrayOfDataToDisplay.count > 0 {

            // inform user "about to build"
            self.willCreateChartAndGraph(arrayOfDataItemsToDisplay: arrayOfDataToDisplay)

            // get the view to put chart in
            let intoView = getTheViewToInsertTheChartAndLegendInto() ?? self.view
let x = intoView?.frame
            // remove old views if already have a chart
            removeOldViewsIfNecessary()

            // build it
            pieChartAndLegend = PieChartAndLegend(arrayOfPieDataObjects: arrayOfDataToDisplay, forView: intoView!)

        } else {

            self.noDataToDispalyInChart()
            
        }

    }

    func removeOldViewsIfNecessary(){

        pieChartAndLegend?.pieChart?.removeFromSuperview()
        pieChartAndLegend?.table?.removeFromSuperview()

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




}




