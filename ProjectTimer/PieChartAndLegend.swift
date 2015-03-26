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
    var parentView:UIView!
    var suggestedPieFrame:CGRect?

    var arrayOfDataToDisplay:[DataItem] = Array()
    var arrayOfPieSlices:[PieSlice] = Array()
    var arrayOfLegendItems = NSMutableArray()


    var colors = [UIColor.redColor(), UIColor.blueColor(), UIColor.brownColor(), UIColor.orangeColor(), UIColor.purpleColor()] as NSArray


    // MARK: BUILD AND UPDATE CHART

    init(arrayOfPieDataObjects:Array<DataItem>, forView:UIView, splitViewBetweenChartAndLegend:Bool){  // if splitViewBetweenChartAndLegend = false, the chart and legend subviews will be stacked one on top of the other and will take up the full view
        super.init()

        parentView = forView

        setScreenElementPositions(forViewWithSize: parentView.frame.size, splitViewBetweenChartAndLegend:splitViewBetweenChartAndLegend)
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

    func setScreenElementPositions(#forViewWithSize:CGSize, splitViewBetweenChartAndLegend:Bool){

        // set chart.frame and legend.frame values

        if splitViewBetweenChartAndLegend == false {

            // set frames
            legendFrame = CGRectMake(0, 0, forViewWithSize.width, forViewWithSize.height)
            suggestedPieFrame = legendFrame

        } else {

            // divide screen in half, one half for table, one half for pie chart
            // if height it taller than width (vertical layout), then divide height in half
            // else, divide width in half

            if forViewWithSize.height > forViewWithSize.width {

                setPositionsInPortraitView(forViewWithSize: forViewWithSize)

            }else{

                setPositionsInLanscapeView(forViewWithSize: forViewWithSize)
                
            }

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
            parentView.addSubview(pieChart!)

        }

        pieChart!.updateUIViewWithEmbeddedPieChart(arrayOfPieSlices:arrayOfPieSlices, desiredHeightAndWidthOfView: suggestedPieFrame!.height)
        pieChart!.frame = CGRectMake(suggestedPieFrame!.origin.x, suggestedPieFrame!.origin.y, pieChart!.frame.width, pieChart!.frame.height)  // set frame in step two, because need results from update

    }

    private func buildLegend(){

        if table == nil {

            table = MCTableWithMutliSelection(frame: legendFrame!, cancelDropWhenTouchOutsideTableAndWithInThisView: parentView)
            table?.color_selectCellForDrag = UIColor.lightGrayColor()

            table?.setDataSourceSwiftHack(self)
            table?.setDelegateSwiftHack(self)

            // in swift, not possible to properly setup forwarding without stupid hack
            // failed code:

            // let delegate:UITableViewDelegate = self as UITableViewDelegate
            // let dataSource:UITableViewDataSource = self as UITableViewDataSource

            // table?.dataSource = dataSource
            // table?.delegate = delegate

            parentView.addSubview(table!)

        }

        table?.arrayOfDataForDisplay = arrayOfLegendItems
        table?.reloadData()

    }


    // create data

    private func buildArrayOfObjectsToDisplayInTable(){

        arrayOfLegendItems.removeAllObjects()
        var counter = 0

        // create a legend item for each data item
        for item in arrayOfDataToDisplay {

            var legend = MCTableDataObject()
            legend.title = item.title
            legend.isSelected = item.isSelected
            legend.wrappedObject = item
            legend.sortPosition = item.indexOfPosition
            arrayOfLegendItems.addObject(legend)

        }
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
        //cell.imageView?.image!.layer.borderColor = UIColor.blackColor().CGColor
        //cell.imageView!.image.layer.borderWidth = 2.0


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

        if delegate != nil {

            let selectedObject = arrayOfLegendItems[indexPath.row] as MCTableDataObject
            let wrappedDataObject = selectedObject.wrappedObject as DataItem
            let originalObjectPassedIn: AnyObject? = wrappedDataObject.pointerToParentObject
            
            delegate?.itemWasSelected(theObjectYouPassedIn: originalObjectPassedIn)

        }

        // update pie chart
        buildArrayOfPieSlicesFromLegendData()
        buildPieChart()

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
        
        // the tableView will move objects into the correct position
        // thus the legend will have the correct order
        // grab these objects

        // then use these data objects to rebuild the ChartAndLegend
        // and finally, notify the dataSource

        rebuildChartAndTableDataAfterDrop()
        notifyDataSourceOfChangeInPositionsAfterDrop()
        
        updatePieChart(arrayOfDataToDisplay)

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


