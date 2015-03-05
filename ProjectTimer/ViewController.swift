//
//  ViewController.swift
//  PieChart
//
//  Created by xcode on 1/21/15.
//  Copyright (c) 2015 MSCline. All rights reserved.
//


import UIKit

class ViewController: UIViewController, MCTable_DataItemProtocol {


        // instance variables
        var arrayOfDataToDisplay:[DataItem] = Array()
        var pieChartAndLegend:PieChartAndLegend?

        var colors:NSArray?
    

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        buildData()

        if arrayOfDataToDisplay.count > 0 {

            pieChartAndLegend = PieChartAndLegend(arrayOfPieDataObjects: arrayOfDataToDisplay, forView: self.view)

        }

    }


    func buildData(){

        // remove old data
        arrayOfDataToDisplay.removeAll(keepCapacity: true)

        // get the selected pie chart
        let selectedPieChart = PieChartThumbnailSubclass.getTheSelectedPieChart()

        // the first time you run it, there will not be a selected chart, just exit
        if selectedPieChart == nil {return;}

        // get the categories from the pie chart object and iterate thru
        for category in selectedPieChart!.chartsCategories {

            // find elapsedTime
            let cat = category as TrackingCategory
            let sum = TrackingCategorySubclass.sumTotalOfLogRecords(parentCategory: cat)
            let elapsedT = sum ?? 0

            cat.totalValue = NSInteger(elapsedT)

            // update db
            var err = NSErrorPointer()
            TrackingCategorySubclass.getMOC().save(err)

            // create data item to pass to pie chart and label class
            let item = DataItem(title: cat.title, color: cat.color as? UIColor, amount: Int(cat.totalValue))
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




