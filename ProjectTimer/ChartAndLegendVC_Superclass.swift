//
//  ViewController.swift
//  PieChart
//
//  Created by xcode on 1/21/15.
//  Copyright (c) 2015 MSCline. All rights reserved.
//


import UIKit

class ChartAndLegendVC_Superclass: UIViewController, MCTable_DataItemProtocol, PieChartAndLegendWasSelected {


        // instance variables (you can access them, but override methods to provide required data)
        var setOfCategoriesToDisplay_yourRawData:NSSet?
        var arrayOfDataToDisplay:[DataItem] = Array()
        var insertIntoView:UIView?
        var splitViewBetweenChartAndLegend = true // otherwise, both will take up full view and will be stacked one on top of the other
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

    func didCreateChartAndGraph(){


    }

    func noDataToDispalyInChart(){

        // if no data to display, can customize view here

    }


    // MARK: PIE CHART DELEGATE METHODS TO OVERRIDE

    func itemWasSelected(#theObjectYouPassedIn: AnyObject?) {

        // override if desired

    }

    func colorWasChangedForItem(#theObjectYouPassedIn: AnyObject?, color: UIColor) {

        // override if desired

    }


    // MARK: HELPER METHOD TO CALL IN SUBCLASSES

    func addSnapShotOfChartToPieChartThumbObject(chart:PieChartThumbnail){

        if pieChartAndLegend == nil || pieChartAndLegend!.pieChart == nil {return;}

        let viewWorkingWith = self.pieChartAndLegend!.pieChart!
        UIGraphicsBeginImageContext(viewWorkingWith.frame.size)
        viewWorkingWith.layer.renderInContext(UIGraphicsGetCurrentContext())
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        chart.snapshot = image
        
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

        // there is no viewDidTransition, but we can pack something in a completion block
        coordinator.animateAlongsideTransition(nil, completion: { (coordinator) -> Void in

            self.buildChartAndLegend()

        })

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

            // remove old views if already have a chart
            removeOldViewsIfNecessary()

            // build it
            pieChartAndLegend = PieChartAndLegend(arrayOfPieDataObjects: arrayOfDataToDisplay, forView: intoView!, splitViewBetweenChartAndLegend: self.splitViewBetweenChartAndLegend)
            pieChartAndLegend!.delegate = self

        } else {

            self.noDataToDispalyInChart()
            
        }

        // notify user that chart is finished
        self.didCreateChartAndGraph()

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
            let cat = category as PieChartCategoryWrapper
            let sum = TrackingCategorySubclass.sumTotalOfLogRecords(parentCategory: cat.catWrappersBaseCategory)
            let elapsedT = sum ?? 0

            cat.catWrappersBaseCategory.totalValue = NSInteger(elapsedT)

            // update db
            var err = NSErrorPointer()
            TrackingCategorySubclass.getMOC().save(err)

            // create data item to pass to pie chart and label class
            let item = DataItem(title:      cat.catWrappersBaseCategory.title,
                                color:      cat.color as? UIColor,
                                amount:     Int(cat.catWrappersBaseCategory.totalValue),
                                isSelected: convertToBool_stupidHelper(cat.isSelected),
                                optional_parentObject: cat,
                                positionInChart:    Double(cat.position))

            arrayOfDataToDisplay.append(item)

        }

        // sort data
        makeSureDataIsSorted()  // the data may have come from a set, so need to sort
        
    }

    func convertToBool_stupidHelper(number:NSNumber)->(Bool){

        // got weird errors, will do manually

        if number == 0 {

            return false

        }else if number == 1 {

            return true

        } else {

            abort()

        }

    }

    func makeSureDataIsSorted(){

        arrayOfDataToDisplay.sort { (a, b) -> Bool in

            let alpha = a as DataItem
            let beta = b as DataItem

            if a.indexOfPosition < b.indexOfPosition {

                return true

            }else{

                return false
            }

        }

    }

    // MARK: CODING

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


}




