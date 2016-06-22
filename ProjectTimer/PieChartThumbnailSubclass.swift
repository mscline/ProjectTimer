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

        let fetchRequest = NSFetchRequest(entityName: "PieChartThumbnail")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "indexNumber", ascending: true)]

        let err = NSErrorPointer()
        let pieCharts: [AnyObject]?
        do {
            pieCharts = try getMOC().executeFetchRequest(fetchRequest)
        } catch let error as NSError {
            err.memory = error
            pieCharts = nil
        }

        if err != nil {print("Error \(err)");}

        return pieCharts! as NSArray

    }

    class func getTheSelectedPieChart() -> (PieChartThumbnail?){

        let err = NSErrorPointer()

        let fetchRequest = NSFetchRequest(entityName: "PieChartThumbnail")
        fetchRequest.predicate = NSPredicate(format: "%K == true", "isSelected")

        let resultsArry: [AnyObject]?
        do {
            resultsArry = try getMOC().executeFetchRequest(fetchRequest)
        } catch let error as NSError {
            err.memory = error
            resultsArry = nil
        }
        let results = resultsArry! as NSArray

        if results.count > 0 {

            return results.objectAtIndex(0) as? PieChartThumbnail

        }else{

            return nil

        }

    }

    class func addPieChart(title title:NSString)->(PieChartThumbnail){

        var pieC = NSEntityDescription.insertNewObjectForEntityForName("PieChartThumbnail", inManagedObjectContext: getMOC()) as! PieChartThumbnail
        pieC.chartTitle = title as String
        pieC.isSelected = true
        pieC.indexNumber = getPieCharts().count

        var err = NSErrorPointer()
        do {
            try getMOC().save()
        } catch var error as NSError {
            err.memory = error
        }

        if err != nil {print("Error \(err)");}

        return pieC

    }

    class func deletePieChart(chart:PieChartThumbnail){

        let err = NSErrorPointer()

        PieChartThumbnailSubclass.getMOC().deleteObject(chart)
        do {
            try PieChartThumbnailSubclass.getMOC().save()
        } catch let error as NSError {
            err.memory = error
        }

    }


    // CD

    class func getMOC() -> NSManagedObjectContext{

        let AppDel = UIApplication.sharedApplication().delegate! as! AppDelegate
        return AppDel.managedObjectContext!
        
    }
    
}
