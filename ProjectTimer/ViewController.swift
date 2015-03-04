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
        pieChartAndLegend = PieChartAndLegend(arrayOfPieDataObjects: arrayOfDataToDisplay, forView: self.view)

        //tester()

    }

    
    // MARK: CODING

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func buildData(){

        arrayOfDataToDisplay.removeAll(keepCapacity: true)
        let categories = TrackingCategorySubclass.returnListOfCategories()

        for category in categories {

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


    // MARK: ROTATIONS

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {

        pieChartAndLegend!.setScreenElementPositions(forViewWithSize: size)

    }


}




