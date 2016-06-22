//
//  PieChartCategoryWrapperSubclass.swift
//  ProjectTimer
//
//  Created by xcode on 3/18/15.
//  Copyright (c) 2015 MSCline. All rights reserved.
//

import UIKit

class PieChartCategoryWrapperSubclass: PieChartCategoryWrapper {

    // the project has basic categories/timers that are shared
    // but each pie chart may customize color, appearance, and select which categories are shown in the chart
    // thus, a pie chart will make a category wrapper for each category

    class func createCategoryWrapperForPieChart(pieChart pieChart:PieChartThumbnail, baseCategory:TrackingCategory, positionIndexNumber:Double)->(PieChartCategoryWrapper){

        var wrapper = NSEntityDescription.insertNewObjectForEntityForName("PieChartCategoryWrapper", inManagedObjectContext: getMOC()) as! PieChartCategoryWrapper

        wrapper.catWrappersBaseCategory = baseCategory;
        wrapper.position = positionIndexNumber
        wrapper.color = baseCategory.color
        wrapper.notUsedInChart = true
        wrapper.isSelected = true

        // add to parent
        pieChart.addPieChartsCategoryWrappersObject(wrapper)

        var err = NSErrorPointer()
        do {
            try getMOC().save()
        } catch var error as NSError {
            err.memory = error
        }

        if err != nil {print("Error \(err)");}

        return wrapper
        
    }


    class func getMOC() -> NSManagedObjectContext{

        let AppDel = UIApplication.sharedApplication().delegate! as! AppDelegate
        return AppDel.managedObjectContext!

    }
    
}
