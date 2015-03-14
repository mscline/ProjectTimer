//
//  PieChartThumbnailSubclass.swift
//  ProjectTimer
//
//  Created by xcode on 3/4/15.
//  Copyright (c) 2015 MSCline. All rights reserved.
//

import UIKit

class PieChartThumbnailSubclass: PieChartThumbnail {

    

    // CRUD

    class func getPieCharts() -> (NSArray){

        var fetchRequest = NSFetchRequest(entityName: "PieChartThumbnail")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "indexNumber", ascending: true)]

        var err = NSErrorPointer()
        let pieCharts = getMOC().executeFetchRequest(fetchRequest, error: err)

        if err != nil {println("Error \(err)");}

        return pieCharts! as NSArray

    }

    class func getTheSelectedPieChart() -> (PieChartThumbnail?){

        var err = NSErrorPointer()

        let fetchRequest = NSFetchRequest(entityName: "PieChartThumbnail")
        fetchRequest.predicate = NSPredicate(format: "%K == true", "isSelected")

        let resultsArry = getMOC().executeFetchRequest(fetchRequest, error: err)
        let results = resultsArry! as NSArray

        if results.count > 0 {

            return results.objectAtIndex(0) as? PieChartThumbnail

        }else{

            return nil

        }

    }

    class func addPieChart(#title:NSString)->(PieChartThumbnail){

        var pieC = NSEntityDescription.insertNewObjectForEntityForName("PieChartThumbnail", inManagedObjectContext: getMOC()) as PieChartThumbnail
        pieC.chartTitle = title
        pieC.isSelected = true
        pieC.indexNumber = getPieCharts().count

        var err = NSErrorPointer()
        getMOC().save(err)

        if err != nil {println("Error \(err)");}

        return pieC

    }

    class func deletePieChart(chart:PieChartThumbnail){

        var err = NSErrorPointer()

        PieChartThumbnailSubclass.getMOC().deleteObject(chart)
        PieChartThumbnailSubclass.getMOC().save(err)

    }


    // CD

    class func getMOC() -> NSManagedObjectContext{

        let AppDel = UIApplication.sharedApplication().delegate! as AppDelegate
        return AppDel.managedObjectContext!
        
    }
    
}
