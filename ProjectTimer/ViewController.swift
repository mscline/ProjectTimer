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


    override func viewDidLoad() {
        super.viewDidLoad()

        buildSampleData()
        pieChartAndLegend = PieChartAndLegend(arrayOfPieDataObjects: arrayOfDataToDisplay, forView: self.view)

        //tester()

    }

    
    // MARK: CODING

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func buildSampleData(){


        let a = DataItem(title: "one", color: UIColor.redColor(), amount: 10)
        let b = DataItem(title: "two", color: UIColor.blueColor(), amount: 20)
        let c = DataItem(title: "three", color: UIColor.yellowColor(), amount: 30)

        arrayOfDataToDisplay.append(a)
        arrayOfDataToDisplay.append(b)
        arrayOfDataToDisplay.append(c)
        
    }


    // MARK: ROTATIONS

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {

        pieChartAndLegend!.setScreenElementPositions(forViewWithSize: size)

    }

    func tester(){

//        TrackingCategorySubclass.addNewTrackingCategory(title: "hey", totalValue: NSNumber(float: 10), color: UIColor.redColor())

        let data = TrackingCategorySubclass.returnListOfCategories()

        let x = data[0] as TrackingCategorySubclass
        let str = x.title
        println(str)

        //TrackingCategorySubclass.delTrackingCategory(obj: x)

    }


}




