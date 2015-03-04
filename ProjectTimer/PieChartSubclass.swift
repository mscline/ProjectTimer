//
//  PieChartSubclass.swift
//  ProjectTimer
//
//  Created by xcode on 3/4/15.
//  Copyright (c) 2015 MSCline. All rights reserved.
//

import UIKit

class PieChartSubclass: PieChart {


    // CRUD

    class func getPieCharts(){

    }

    class func addPieChart(#title:NSString){

        let pieChart = NSEntityDescription.insertNewObjectForEntityForName("PieChart", inManagedObjectContext: PieChartSubclass.getMOC()) as PieChart
        pieChart.title

        let err = NSErrorPointer()
        getMOC().save(err)

    }

    class func deletePieChart(){

    }

    class func editPieChart(){


    }

    // CD

    class func getMOC() -> NSManagedObjectContext{

        let AppDel = UIApplication.sharedApplication().delegate! as AppDelegate
        return AppDel.managedObjectContext!
        
    }

}
