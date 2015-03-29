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

    func willCreateChartAndGraph(#arrayOfDataItemsToDisplay:[DataItem]!){

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
    
    func itemWasSelected(#theObjectYouPassedIn: AnyObject?) {

        // override if desired

        let categoryWrapperObj = theObjectYouPassedIn as PieChartCategoryWrapper

        // !!! need to refetch object (for some reason, it is not live) !!!
        var err = NSErrorPointer()
        let catWrapper = PieChartCategoryWrapperSubclass.getMOC().existingObjectWithID(categoryWrapperObj.objectID, error: err) as PieChartCategoryWrapper

        // toggle isSelected value
        // (this will just change our check mark here, but in the stats controller it means it will not be included)
        let shouldBeSelected = catWrapper.isSelected as Bool
        catWrapper.isSelected = !shouldBeSelected

        // save updates
        let didSave = PieChartCategoryWrapperSubclass.getMOC().save(err)
        if err != nil || didSave == false { println("error: \(err)")}
        
    }

    func colorWasChangedForItem(#theObjectYouPassedIn: AnyObject?, color: UIColor) {

        // SAVE COLOR FOR ITEM (you do not need to update the view)

        let categoryWrapperObj = theObjectYouPassedIn as PieChartCategoryWrapper

        // !!! need to refetch object (for some reason, it is not live) !!!
        var err = NSErrorPointer()
        let catWrapper = PieChartCategoryWrapperSubclass.getMOC().existingObjectWithID(categoryWrapperObj.objectID, error: err) as PieChartCategoryWrapper

        // update color
        catWrapper.color = color

        // save updates
        let didSave = PieChartCategoryWrapperSubclass.getMOC().save(err)
        if err != nil || didSave == false { println("error: \(err)")}
        
    }
    
    func objectMovedToNewPosition(#theObjectYouPassedIn: AnyObject?, position: Int) {

        // save position (you do not need to update the view)

        let categoryWrapperObj = theObjectYouPassedIn as PieChartCategoryWrapper

        // !!! need to refetch object (for some reason, it is not live) !!!
        var err = NSErrorPointer()
        let catWrapper = PieChartCategoryWrapperSubclass.getMOC().existingObjectWithID(categoryWrapperObj.objectID, error: err) as PieChartCategoryWrapper

        // update position
        catWrapper.position = position

        // save updates
        let didSave = PieChartCategoryWrapperSubclass.getMOC().save(err)
        if err != nil || didSave == false { println("error: \(err)")}

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

    override func viewDidLayoutSubviews() {
        super.viewWillLayoutSubviews()

        // only want to build the table after layout configured in layoutSubviews
        // but building the chart will cause it to be called a second time

        // want to only run build chart method once, so add bool to track if build
        // reset it on rotate or when leave view

        if pleaseRebuildTableViewForCurrentLayout == true {

            buildChartAndLegend()
            pleaseRebuildTableViewForCurrentLayout = false

        }

    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        pleaseRebuildTableViewForCurrentLayout = true

    }

    // MARK: ROTATIONS
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {

        // there is no viewDidTransition, but we can pack something in a completion block
        coordinator.animateAlongsideTransition(nil, completion: { (coordinator) -> Void in

            self.pleaseRebuildTableViewForCurrentLayout = true  // don't want to rebuild here, get inconsistent results

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




