//
//  PieChartAndLegend.swift
//  PieChart
//
//  Created by xcode on 2/16/15.
//  Copyright (c) 2015 MSCline. All rights reserved.
//

import UIKit

protocol PieChartAndLegendWasSelected {

    // you may want to update your datasource
    func itemWasSelected(#theObjectYouPassedIn:AnyObject?)->()
    func colorWasChangedForItem(#theObjectYouPassedIn:AnyObject?, color:UIColor)->()
    func objectMovedToNewPosition(#theObjectYouPassedIn:AnyObject?, position:Int)->()

}


class PieChartAndLegend: NSObject {


    // [PUBLIC] INSTANCE VARIABLES
    var pieChart:PieChart?                  // the pie chart is a UIView
    var table:MCTableWithMutliSelection?
    var delegate:PieChartAndLegendWasSelected?

    var legendFrame:CGRect?
    var minPaddingForPieChart:CGFloat = 15.0


    // INSTANCE VARIABLES
    var parentViewForLegend:UIView!
    var parentViewForPieChart:UIView!
    var suggestedPieFrame:CGRect?

    var arrayOfDataToDisplay:[DataItem] = Array()
    var arrayOfPieSlices:[PieSlice] = Array()
    var arrayOfLegendItems = NSMutableArray()


    var colors = [UIColor.redColor(), UIColor.blueColor(), UIColor.brownColor(), UIColor.orangeColor(), UIColor.purpleColor()] as NSArray


    // MARK: BUILD AND UPDATE CHART

    init(arrayOfPieDataObjects:Array<DataItem>, forSplitView:UIView!){
        super.init()

        parentViewForLegend = forSplitView
        parentViewForPieChart = forSplitView

        setScreenElementPositions()
        updatePieChart(arrayOfPieDataObjects)

    }

    init(arrayOfPieDataObjects:Array<DataItem>, forLegendsParentView:UIView!, forPieChartsParentView:UIView!){
        super.init()

        // save views and set frames sizes
        parentViewForLegend = forLegendsParentView
        parentViewForPieChart = forPieChartsParentView

        legendFrame = CGRectMake(0, 0, parentViewForLegend.frame.size.width, parentViewForLegend.frame.size.height)
        suggestedPieFrame = CGRectMake(0, 0, parentViewForPieChart.frame.size.width, parentViewForPieChart.frame.size.height)

        // update
        updatePieChart(arrayOfPieDataObjects)
        
    }

    func updatePieChart(withArrayOfPieDataObjects:Array<DataItem>){

        arrayOfDataToDisplay = withArrayOfPieDataObjects

        buildArrayOfObjectsToDisplayInTable()
        buildArrayOfPieSlicesFromLegendData()

        buildPieChart()
        buildLegend()

    }


    // MARK: layout

    func setScreenElementPositions(){

        // divide screen in half, one half for table, one half for pie chart
        // if in portrait, display vertically
        // if in landscape, display horizontally

        // if height it taller than width (vertical layout), then divide height in half
        // else, divide width in half

        let forViewWithSize = parentViewForLegend.frame.size

        if forViewWithSize.height > forViewWithSize.width {

            setPositionsInPortraitView(forViewWithSize: forViewWithSize)

        }else{

            setPositionsInLanscapeView(forViewWithSize: forViewWithSize)

        }

    }


    func setPositionsInPortraitView(#forViewWithSize:CGSize){


        // set legend
        legendFrame = CGRectMake(0, forViewWithSize.height/2, forViewWithSize.width, forViewWithSize.height/2)

        // set up suggestedPieFrame (the pie chart is going to fit the chart within the top half of the view)
        let pieHeight:CGFloat = forViewWithSize.height / 2 - 2 * minPaddingForPieChart
        let pieWidth:CGFloat = pieHeight

        let pieOriginX:CGFloat = 0.5 * (forViewWithSize.width - forViewWithSize.height/2) + minPaddingForPieChart // the left padding is the width of the view - the width of the chart / 2
        let pieOriginY:CGFloat = minPaddingForPieChart

        suggestedPieFrame = CGRectMake(pieOriginX, pieOriginY, pieWidth, pieHeight)


    }

    func setPositionsInLanscapeView(#forViewWithSize:CGSize){


        // set legends
        legendFrame = CGRectMake(forViewWithSize.width/2.0, 0, forViewWithSize.width/2.0, forViewWithSize.height)

        // set up suggestedPieFrame (the pie chart is going to fit the chart within the top half of the view)
        let pieHeight:CGFloat = forViewWithSize.height - 2 * minPaddingForPieChart
        let pieWidth:CGFloat = pieHeight

        let pieOriginX:CGFloat = (forViewWithSize.width - pieWidth * 2)/4
        let pieOriginY:CGFloat = minPaddingForPieChart

        suggestedPieFrame = CGRectMake(pieOriginX, pieOriginY, pieWidth, pieHeight)

    }


    // MARK: build components / update data

    private func buildPieChart(){

        if pieChart == nil{

            pieChart = PieChart()
            parentViewForPieChart.addSubview(pieChart!)

        }

        pieChart!.updateUIViewWithEmbeddedPieChart(arrayOfPieSlices:arrayOfPieSlices, desiredHeightAndWidthOfView: suggestedPieFrame!.height)
        pieChart!.frame = CGRectMake(suggestedPieFrame!.origin.x, suggestedPieFrame!.origin.y, pieChart!.frame.width, pieChart!.frame.height)  // set frame in step two, because need results from update

    }

    private func buildLegend(){

        if table == nil {

            table = MCTableWithMutliSelection(frame: legendFrame!, cancelDropWhenTouchOutsideTableAndWithInThisView: parentViewForLegend)
            table?.color_selectCellForDrag = UIColor.lightGrayColor()
            table?.doNotAutomaticallyReloadCellOn_didSelectRowAtIndexPath = true

            table?.setDataSourceSwiftHack(self)
            table?.setDelegateSwiftHack(self)

            // in swift, not possible to properly setup forwarding without stupid hack
            // failed code:

            // let delegate:UITableViewDelegate = self as UITableViewDelegate
            // let dataSource:UITableViewDataSource = self as UITableViewDataSource

            // table?.dataSource = dataSource
            // table?.delegate = delegate

            parentViewForLegend.addSubview(table!)

        }

        table?.arrayOfDataForDisplay = arrayOfLegendItems
        table?.reloadData()

    }


    // create data

    private func buildArrayOfObjectsToDisplayInTable(){

        arrayOfLegendItems.removeAllObjects()
        var counter = 0

        let sumOfAllCategories = helper_getSumOfAllItemsValue()

        // create a legend item for each data item
        for item in arrayOfDataToDisplay {

            var legend = MCTableDataObject()
            legend.title = item.title
            legend.subtitle = buildSubtitle(category: item, elapsedTimeForSelectedCategory:item.amount, totalTime: sumOfAllCategories)
            legend.isSelected = item.isSelected
            legend.wrappedObject = item
            legend.sortPosition = item.indexOfPosition
            arrayOfLegendItems.addObject(legend)

        }
    }

    private func buildSubtitle(#category:DataItem, elapsedTimeForSelectedCategory:Int?, totalTime:Float)->(String){

        // deal with optionals
        var elapsedTime = elapsedTimeForSelectedCategory ?? 0
        if totalTime == 0 { return "";}

        // if the category is not selected, do not display detail info
        if category.isSelected == false {return "";}

        // make string with amount of time passed in it
        let timePassed = helper_formatTime(elapsedTime)

        // make string with percentage of total
        let categorysPercentageOfTotalTimePassed:Float = Float(elapsedTime) / totalTime
        var percentageWithOneDecimalPlaces = (Float(Int(categorysPercentageOfTotalTimePassed*1000))/10)

        // round up if needed
        let whatIsTheValueOfTheNumberInTheHundredthsDecPlace = categorysPercentageOfTotalTimePassed * 1000 - Float(Int(categorysPercentageOfTotalTimePassed * 1000))

        if whatIsTheValueOfTheNumberInTheHundredthsDecPlace >= 0.5 {

            percentageWithOneDecimalPlaces = percentageWithOneDecimalPlaces + 0.1
        }

        let percentageAsString = "(\(percentageWithOneDecimalPlaces)%)"

        // combine strings and return
        let combinedString = "\(timePassed) \(percentageAsString)"
        return combinedString

    }

    private func helper_getSumOfAllItemsValue()->(Float){

        var total:Float = 0.0

        // go through all data items being display, if it is selected, then add to sum
        for slice in arrayOfDataToDisplay {

            if slice.isSelected == true {

                let amount = slice.amount ?? 0
                total = total + Float(amount)

            }
        }

        return total
    }

    private func helper_formatTime(elapsedTime:Int!)->(String){

        // CALC DAYS, HOURS, MIN, SEC, HUNDRETHS (just did it by hand, alternatively could have used function)

        // how many days have passed
        // convert seconds into days = (1 min / 60 sec)(1 hour / 60 min)(1 day / 24 hours) with no remainder
        let days = Int(elapsedTime / (3600 * 24))  // take Int do no remainder

        // how much time is remaining
        let remainingTime = elapsedTime - (days * (3600 * 24))

        // number of hours = time in sec (1 hour / 60 min)(1 min / 60 sec) with no remainder
        let hours = Int(remainingTime / 3600)

        // min
        // 1) the number of min is what is left over after we have taken the hours out - use mod 3600
        // 2) number of min = time in sec (1 min / 60 sec) with no remainder
        let min = Int((remainingTime % 3600)/60)

        // sec - whatever is left, after you remove the hours and min
        let sec = Int(remainingTime % 60)

        
        
        // BUILD STRING
        var buildString_sec = ""
        var buildString_minutes = ""
        var buildString_hours = ""
        var buildString_days = ""

        // sec
        if sec == 1 {

            buildString_sec = "\(sec) second "

        }else{

            buildString_sec = "\(sec) seconds "

        }

        // min
        if min == 1 {

            buildString_minutes = "\(min) minute "

        } else if min > 1 {

            buildString_minutes = "\(min) minutes "
        }

        // hours
        if hours == 1 {

            buildString_sec = ""
            buildString_hours = "\(hours) hour "

        }else if hours > 1 {

            buildString_sec = ""
            buildString_hours = "\(hours) hours "
            
        }

        // days
        if days == 1 {

            buildString_minutes = "\(min) min. "
            buildString_days = "\(days) day "

        }else if days > 1 {

            buildString_minutes = "\(min) min. "
            buildString_days = "\(days) days "

        }

        // put strings together
        let buildString = buildString_days + buildString_hours + buildString_minutes + buildString_sec
        return buildString
        
    }

    private func buildArrayOfPieSlicesFromLegendData(){

        // for each selected legend item, create a piece of pie

        arrayOfPieSlices.removeAll(keepCapacity: true)
        var counter = 0  // is this really being used?

        // create a pie slice data object for each item
        for item in arrayOfLegendItems{

            let legendItem = item as MCTableDataObject

            // if isSelect / has checkmark
            if legendItem.isSelected == true {

                let embeddedDataObject = legendItem.wrappedObject as DataItem
                var sliceOfPie = PieSlice(titleForLegend: embeddedDataObject.title!, colorOfPieSlice: embeddedDataObject.color!, positionOfPieSlice_indexNumber: Int(counter), theTotal: embeddedDataObject.amount!)
                sliceOfPie.pointerToDataObjectIfDesired = embeddedDataObject  // here, we are creating a filtered parallel array, so it may be handy to keep a pointer back

                arrayOfPieSlices.append(sliceOfPie)

            }
        }
    }


    // MARK: TABLEVIEW DELEGATES (rem: this is a custom subclass of tableview - implementing protocol not required due to forwarding, ie, all methods optional)

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {

        // going to make a couple little edits in willDisplayCell, since cellForRowAtIndexPath is already being used by the table (thus giving us all that free functionality)
        let tableViewItem = arrayOfLegendItems.objectAtIndex(indexPath.row) as MCTableDataObject

        let dataObject = tableViewItem.wrappedObject as DataItem
        let legendColor = dataObject.color

        // rather than customizing our table view cells and having to do extra work, we are just going to use the existing imageView on our cell
        cell.imageView?.image = UIImage(named: "clearImage.png")
        cell.imageView?.backgroundColor = legendColor

        // add black border around
        cell.imageView?.layer.borderColor = UIColor.blackColor().CGColor
        cell.imageView!.layer.borderWidth = 1.0


        // and add swipe gesture recognizer if required
        if cell.gestureRecognizers?.count == nil {

            var leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("swipeReceived:"))
            leftSwipe.direction = .Left
            cell.addGestureRecognizer(leftSwipe)

            var rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("swipeReceived:"))
            rightSwipe.direction = .Right
            cell.addGestureRecognizer(rightSwipe)

        }

    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        // get corresponding data object
        let selectedObject = arrayOfLegendItems[indexPath.row] as MCTableDataObject
        let wrappedDataObject = selectedObject.wrappedObject as DataItem

        // toggle data objects is selected property
        // (the table would take care of this itself, but we want to recalc our percentage of total value, so we will need to rebuild the chart and legend; this means that we need to update the data items used by the chart and legend)
        let isSelected = wrappedDataObject.isSelected

        if isSelected == nil || isSelected == false {

            wrappedDataObject.isSelected = true

        }else{

            wrappedDataObject.isSelected = false

        }

        // notify delegate
        if delegate != nil {


            let originalObjectPassedIn: AnyObject? = wrappedDataObject.pointerToParentObject
            
            delegate?.itemWasSelected(theObjectYouPassedIn: originalObjectPassedIn)

        }

        //update pie chart
        updatePieChart(arrayOfDataToDisplay)

    }

    func tableView_dataObjects_orderDidChange() {

        updatePositionsAfterDrop()

    }


    // MARK: SWIPE TO CHANGE COLOR

    func swipeReceived(sender:UISwipeGestureRecognizer) {

        if delegate == nil { return; }

        // get index path for cell
        let selectedCell = sender.view as UITableViewCell
        let indexPath = table?.indexPathForCell(selectedCell)
        if indexPath == nil { return;}

        // get data object
        let correspondingLegendItem = arrayOfLegendItems.objectAtIndex(indexPath!.row) as MCTableDataObject
        let dataObject = correspondingLegendItem.wrappedObject as DataItem
        let originalObjectPassedIn: AnyObject? = dataObject.pointerToParentObject

        // get next color
        let nextColor = getNextColor(sender: sender, cell: selectedCell)

        // notify delegate will change color so it can save, etc.
        delegate?.colorWasChangedForItem(theObjectYouPassedIn: originalObjectPassedIn, color: nextColor)

        // we don't want to ask the dataSource to requery (who knows how the data is managed), so change the local pie and legend data (our views)
        dataObject.color = nextColor  // note: we didn't have to do this for the checkmark, because we were just updating our data objects and rebuilding

        // update pie chart
        updatePieChart(arrayOfDataToDisplay)

    }

    func getNextColor(#sender:AnyObject, cell:UITableViewCell)->(UIColor){


        let currentColor = cell.imageView?.backgroundColor

        // get next color
        var colorIndex = helper_getIndexForCurrentColorOrReturn0(color: currentColor)

        if (sender.direction == .Left) {

            colorIndex = colorIndex + 1

        }else if (sender.direction == .Right) {

            colorIndex = colorIndex - 1

        }

        if colorIndex < 0 { colorIndex = colors.count - 1; }
        if colorIndex >= colors.count { colorIndex = 0; }

        let nextColor = colors.objectAtIndex(colorIndex) as UIColor
        return nextColor

    }

    func helper_getIndexForCurrentColorOrReturn0(#color:UIColor?)->(Int){

        if color == nil { return 0; }

        var index = 0

        for colorInList in colors {

            let theColorInList = colorInList as UIColor

            if theColorInList == color {

                return index

            }

            index++

        }

        return 0

    }

    // MARK: UPDATE POSITIONS

    func updatePositionsAfterDrop(){

        // save a copy of our data
        var arrayOfLegendItemsCurrentlyDisplayedInTable = table!.arrayOfDataForDisplay.copy() as NSArray

        // the tableView will move objects into the correct position
        // thus the legend will have the correct order
        // grab these objects

        // then use these data objects to rebuild the ChartAndLegend
        // this will put the pie chart and legend colors in order
        // and don't forget to, notify the dataSource

        rebuildChartAndTableDataAfterDrop()
        notifyDataSourceOfChangeInPositionsAfterDrop()

        buildArrayOfObjectsToDisplayInTable()
        buildArrayOfPieSlicesFromLegendData()

        editTableDataToIncludeWasHighlightedInfoForFadeEffect(arrayOfLegendItemsCurrentlyDisplayedInTable)

        buildPieChart()
        buildLegend()

    }

    func editTableDataToIncludeWasHighlightedInfoForFadeEffect(originalArray:NSArray!){

        // when we rebuilt the pie chart, lost some of our data
        // our new data and our old data will be in the same order
        // so we can iterate thru both lists and update

        for var x = 0; x < originalArray.count; x++ {

            let oldDataObject = originalArray[x] as MCTableDataObject
            var futureDataObject = arrayOfLegendItems[x] as MCTableDataObject

            if oldDataObject.isHighlightForDrag == 1 {  // 2 = slowlyFade (swift doesn't like my objC enums)

                futureDataObject.isHighlightForDrag = 1

            }

        }

    }

    func rebuildChartAndTableDataAfterDrop(){

        arrayOfDataToDisplay.removeAll(keepCapacity: true)

        var position:Double = 0

        for tableDataObject in table!.arrayOfDataForDisplay {

            let wrappedLegendAndChartDataObject = tableDataObject.wrappedObject as DataItem
            wrappedLegendAndChartDataObject.indexOfPosition = position
            position++

            arrayOfDataToDisplay.append(wrappedLegendAndChartDataObject)
            
        }

    }

    func notifyDataSourceOfChangeInPositionsAfterDrop(){

        // update data source
        var index = 0

        for chartAndLegendObject in arrayOfDataToDisplay {

            // get original data object
            let originalObjectYouPassedIn:AnyObject? = chartAndLegendObject.pointerToParentObject as AnyObject?

            // update chart and legend
            delegate?.objectMovedToNewPosition(theObjectYouPassedIn: originalObjectYouPassedIn, position: index)
            
            index++
            
        }
    }

    
}


