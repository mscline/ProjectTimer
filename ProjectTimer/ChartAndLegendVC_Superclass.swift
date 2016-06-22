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

        // other
        var pleaseRebuildTableViewForCurrentLayout = true  // see discussion in lifecycle section


    // xxxxxxxxxxxxxxxxxxxxxxx
    // MARK: METHODS TO OVERRIDE IF SUBCLASSING
    // xxxxxxxxxxxxxxxxxxxxxxx

    func getThePieChartCategoriesYouWantToDisplay_OverrideHereIfSubclassing() -> (NSSet) {

        return NSSet()

    }

    func getTheViewToInsertTheChartInto()->(UIView?){

        return nil
    }

    func layoutChartAndLegendInSeparateViews_viewNumberTwoForLegend()->(UIView?){

        // you could always move the position of the pie chart or legend subviews programmatically
        // but you cannot easily resize them
        // use a second view to set your size (whether programmatically or using storyboard constraints)

        return nil
    }

    func willCreateChartAndGraph(arrayOfDataItemsToDisplay arrayOfDataItemsToDisplay:[DataItem]!){

        // last chance to make any changes (eg, change dataItem.isSelected = true)

    }

    func didCreateChartAndGraph(){

        pieChartAndLegend?.table?.separatorColor = UIColor.clearColor()

    }

    func noDataToDispalyInChart(){

        // if no data to display, can customize view here

    }


    // MARK: PIE CHART DELEGATE METHODS (YOU CAN OVERRIDE IN SUBCLASS)
    //       WE ARE JUST GOING TO SAVE UPDATED DATA
    
    func itemWasSelected(theObjectYouPassedIn theObjectYouPassedIn: AnyObject?) {

        // override if desired

        let categoryWrapperObj = theObjectYouPassedIn as! PieChartCategoryWrapper
        let err = NSErrorPointer()

        // !!! need to refetch object (for some reason, it is not live) !!!
        do {
            let catWrapper = try PieChartCategoryWrapperSubclass.getMOC().existingObjectWithID(categoryWrapperObj.objectID) as! PieChartCategoryWrapper


            // toggle isSelected value
            // (this will just change our check mark here, but in the stats controller it means it will not be included)
            let shouldBeSelected = catWrapper.isSelected as Bool
            catWrapper.isSelected = !shouldBeSelected

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

    func colorWasChangedForItem(theObjectYouPassedIn theObjectYouPassedIn: AnyObject?, color: UIColor) {

        // SAVE COLOR FOR ITEM (you do not need to update the view)

        let categoryWrapperObj = theObjectYouPassedIn as! PieChartCategoryWrapper

        // !!! need to refetch object (for some reason, it is not live) !!!
        let err = NSErrorPointer()

        do {

            let catWrapper = try PieChartCategoryWrapperSubclass.getMOC().existingObjectWithID(categoryWrapperObj.objectID) as! PieChartCategoryWrapper

            // update color
            catWrapper.color = color

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
    
    func objectMovedToNewPosition(theObjectYouPassedIn theObjectYouPassedIn: AnyObject?, position: Int) {

        // save position (you do not need to update the view)

        let categoryWrapperObj = theObjectYouPassedIn as! PieChartCategoryWrapper

        // !!! need to refetch object (for some reason, it is not live) !!!
        let err = NSErrorPointer()
        do {
            let catWrapper = try PieChartCategoryWrapperSubclass.getMOC().existingObjectWithID(categoryWrapperObj.objectID) as! PieChartCategoryWrapper

            // update position
            catWrapper.position = position

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
    
    // MARK: HELPER METHOD TO CALL IN SUBCLASSES

    func addSnapShotOfChartToPieChartThumbObject(chart:PieChartThumbnail){

        if pieChartAndLegend == nil || pieChartAndLegend!.pieChart == nil {return;}

        let viewWorkingWith = self.pieChartAndLegend!.pieChart!
        UIGraphicsBeginImageContext(viewWorkingWith.frame.size)
        viewWorkingWith.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        chart.snapshot = image
        
    }

    // xxxxxxxxxxxxxxxxxxxxxxx
    // xxxxxxxxxxxxxxxxxxxxxxx


    // MARK: LIFECYCLE

    override func viewDidLayoutSubviews() {
        super.viewWillLayoutSubviews()

        // only want to build the table after layout configured in layoutSubviews
        // but building the chart will cause it to be called a second time

        // want to only run build chart method once, so add bool to track if build
        // reset it on rotate or when leave view

        if pleaseRebuildTableViewForCurrentLayout == true {

            buildChartAndLegend()
            pleaseRebuildTableViewForCurrentLayout = false

            // note: will need to do two things in viewWillDisappear
            // 1) change the value of pleaseRebuildTableViewForCurrentValue to true
            // 2) Apple will store the old view in memory and skip calling viewWillLayoutSubviews when return; thus need to tell it that the layout will need to be updated using
            //
            //      self.view.setNeedsLayout()

        }

    }

    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        pleaseRebuildTableViewForCurrentLayout = true
        self.view.setNeedsLayout()

    }

    // MARK: ROTATIONS
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {

        // there is no viewDidTransition, but we can pack something in a completion block
        coordinator.animateAlongsideTransition(nil, completion: { (coordinator) -> Void in

            self.pleaseRebuildTableViewForCurrentLayout = true  // don't want to rebuild here, get inconsistent results
            self.view.setNeedsLayout()

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
            let putPieIntoView = getTheViewToInsertTheChartInto() ?? self.view

            // remove old views if already have a chart
            removeOldViewsIfNecessary()

            // build it
            let viewForLegend_meansWillLayoutInDifViews = layoutChartAndLegendInSeparateViews_viewNumberTwoForLegend()

            if viewForLegend_meansWillLayoutInDifViews == nil {

                // layout both views in split view configuration
                pieChartAndLegend = PieChartAndLegend(arrayOfPieDataObjects: arrayOfDataToDisplay, forSplitView: putPieIntoView)

            }else{

                // layout in dif views
                pieChartAndLegend = PieChartAndLegend(arrayOfPieDataObjects: arrayOfDataToDisplay, forLegendsParentView: viewForLegend_meansWillLayoutInDifViews, forPieChartsParentView: putPieIntoView)

            }


            pieChartAndLegend!.delegate = self
            pieChartAndLegend!.colors = colors!

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
            let cat = category as! PieChartCategoryWrapper
            let sum = TrackingCategorySubclass.sumTotalOfLogRecords(parentCategory: cat.catWrappersBaseCategory)
            let elapsedT = sum ?? 0

            cat.catWrappersBaseCategory.totalValue = NSInteger(elapsedT)

            // update db
            let err = NSErrorPointer()
            do {
                try TrackingCategorySubclass.getMOC().save()
            } catch let error as NSError {
                err.memory = error
            }

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

        arrayOfDataToDisplay.sortInPlace { (a, b) -> Bool in

            if a.indexOfPosition < b.indexOfPosition {

                return true

            }else{

                return false
            }

        }

    }

    // MARK: CODING

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


}




