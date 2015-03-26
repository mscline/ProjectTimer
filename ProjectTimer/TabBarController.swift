//
//  TabBarController.swift
//  ProjectTimer
//
//  Created by xcode on 3/3/15.
//  Copyright (c) 2015 MSCline. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {


        // constants
        let colors:NSArray = [UIColor.blueColor(), UIColor.redColor(), UIColor.purpleColor(), UIColor.orangeColor(), UIColor.yellowColor(), UIColor.brownColor(), UIColor.cyanColor(), UIColor.magentaColor()]
        let colorNames:NSArray = ["Blue", "Red", "Purple", "Orange", "YellowColor", "BrownColor", "CyanColor","MagentaColor"]  // I don't know of a method to get it and rather than creating a lookup dict, lets go with quick and dirty


    override func viewDidLoad() {
        super.viewDidLoad()

        passColorsToChildViewControllers()

        // start with the center tab
//        let vcs = self.viewControllers! as NSArray
//        self.selectedViewController = vcs.objectAtIndex(1) as UINavigationController

        // add sample data on first load
        let userDefaults = NSUserDefaults()

        if userDefaults.boolForKey("notFirstLogIn") == false {

            addSampleData()

            userDefaults.setBool(true, forKey: "notFirstLogIn")
            userDefaults.synchronize()

        }

    }

    func addSampleData(){

        sampleData_pieChart_timeSpentCoding()

    }

    func sampleData_pieChart_timeSpentCoding(){

        // build chart
        let pieChart = PieChartThumbnailSubclass.addPieChart(title: "Coding")

        // create categories
        let catA = TrackingCategorySubclass.addNewTrackingCategory(title: "Planning", totalValue: 100, color: UIColor.purpleColor())


        let catB = TrackingCategorySubclass.addNewTrackingCategory(title: "Coding", totalValue: 100, color: UIColor.blueColor())
        let catC = TrackingCategorySubclass.addNewTrackingCategory(title: "Refactoring", totalValue: 100, color: UIColor.yellowColor())
        let catD = TrackingCategorySubclass.addNewTrackingCategory(title: "Debug", totalValue: 100, color: UIColor.redColor())
        let catE = TrackingCategorySubclass.addNewTrackingCategory(title: "Other", totalValue: 100, color: UIColor.brownColor())  // should remove total value from method???
        catE.timerIsHidden = true  // moc will be updated by future method calls

        // create category wrappers (containing the categories), to attach to pie chart
        var catW1 = PieChartCategoryWrapperSubclass.createCategoryWrapperForPieChart(pieChart: pieChart, baseCategory: catA, positionIndexNumber: 0)
        var catW2 = PieChartCategoryWrapperSubclass.createCategoryWrapperForPieChart(pieChart: pieChart, baseCategory: catB, positionIndexNumber: 1)
        var catW3 = PieChartCategoryWrapperSubclass.createCategoryWrapperForPieChart(pieChart: pieChart, baseCategory: catC, positionIndexNumber: 2)
        var catW4 = PieChartCategoryWrapperSubclass.createCategoryWrapperForPieChart(pieChart: pieChart, baseCategory: catD, positionIndexNumber: 3)

        // by default, category wrappers are hidden, change it
        catW1.notUsedInChart = false
        catW2.notUsedInChart = false
        catW3.notUsedInChart = false
        catW4.notUsedInChart = false


        // add log records
        let logA = LogRecordSubclass.addNewLogRecord(checkinTime: NSDate(), parentCategory: catA)
        let logB = LogRecordSubclass.addNewLogRecord(checkinTime: NSDate(), parentCategory: catB)
        let logC = LogRecordSubclass.addNewLogRecord(checkinTime: NSDate(), parentCategory: catC)
        let logD = LogRecordSubclass.addNewLogRecord(checkinTime: NSDate(), parentCategory: catD)
        let logE = LogRecordSubclass.addNewLogRecord(checkinTime: NSDate(), parentCategory: catE)

        // log records are not created with a checkout time, so add it
        updateLastLogUponCheckout(record: logA, timeInterval: 3000)
        updateLastLogUponCheckout(record: logB, timeInterval: 2400)
        updateLastLogUponCheckout(record: logC, timeInterval: 2700)
        updateLastLogUponCheckout(record: logD, timeInterval: 3200)
        updateLastLogUponCheckout(record: logE, timeInterval: 300)

    }

    // helper method for creating sample data
    func updateLastLogUponCheckout(#record:LogRecord, timeInterval:Double){

        record.checkoutTime = NSDate().dateByAddingTimeInterval(timeInterval)
        var err = NSErrorPointer()
        LogRecordSubclass.getMOC().save(err)

    }

    func passColorsToChildViewControllers(){

        for nav in self.childViewControllers {

            let navC = nav as UINavigationController
            let vc = navC.viewControllers[0] as UIViewController

            if vc.isKindOfClass(ChartAndLegendVC_Superclass){

                let ourVC = vc as ChartAndLegendVC_Superclass
                ourVC.colors = colors

            }

            if vc.isKindOfClass(TimerViewController){

                let ourVC = vc as TimerViewController
                ourVC.colors = colors
                ourVC.colorNames = colorNames
                
            }

            if vc.isKindOfClass(PieChartsViewController){

                let ourVC = vc as PieChartsViewController
                ourVC.colors = colors

            }
            
        }

    }

}
