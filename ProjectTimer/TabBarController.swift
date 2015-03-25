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

return

        let catB = TrackingCategorySubclass.addNewTrackingCategory(title: "Coding", totalValue: 100, color: UIColor.blueColor())
        let catC = TrackingCategorySubclass.addNewTrackingCategory(title: "Refactoring", totalValue: 100, color: UIColor.yellowColor())
        let catD = TrackingCategorySubclass.addNewTrackingCategory(title: "Debug", totalValue: 100, color: UIColor.redColor())
        let catE = TrackingCategorySubclass.addNewTrackingCategory(title: "Other", totalValue: 100, color: UIColor.brownColor())  // should remove total value from method???
        catE.timerIsHidden = 1  // moc will be updated by future method calls

        // add categories to pie chart
//        pieChart.addChartsCategoriesObject(catA)
//        pieChart.addChartsCategoriesObject(catB)
//        pieChart.addChartsCategoriesObject(catC)
//        pieChart.addChartsCategoriesObject(catD)
//        pieChart.addChartsCategoriesObject(catE)

        // add log records
        let logA = LogRecordSubclass.addNewLogRecord(checkinTime: NSDate(), parentCategory: catA)
        let logB = LogRecordSubclass.addNewLogRecord(checkinTime: NSDate(), parentCategory: catB)
        let logC = LogRecordSubclass.addNewLogRecord(checkinTime: NSDate(), parentCategory: catC)
        let logD = LogRecordSubclass.addNewLogRecord(checkinTime: NSDate(), parentCategory: catD)
        let logE = LogRecordSubclass.addNewLogRecord(checkinTime: NSDate(), parentCategory: catE)

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

            if vc.isKindOfClass(StatsViewController){

                let ourVC = vc as StatsViewController
                ourVC.colors = colors

            }

            if vc.isKindOfClass(TimerViewController){

                let ourVC = vc as TimerViewController
                ourVC.colors = colors
                ourVC.colorNames = colorNames
                
            }
        }

    }

}
