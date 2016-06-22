//
//  TrackingCategorySubclass.swift
//  ProjectTimer
//
//  Created by xcode on 2/17/15.
//  Copyright (c) 2015 MSCline. All rights reserved.
//

// !!! WHEN WORKING WITH SWIFT
// 1) only add class methods to your subclass, or won't run
// 2) when creating/casting objects, always cast them as your apple generated managed object (not your subclass) in order to avoid annoying breakpoint issues

import UIKit

class TrackingCategorySubclass: TrackingCategory {


    var wouldLikeLegendToDisplayAsSelected:Bool = false  // we will pass an array of categories 

    // from superclass

    //    @property (nonatomic, retain) NSString * title;
    //    @property (nonatomic, retain) NSNumber * totalValue;
    //    @property (nonatomic, retain) id color;
    //    @property (nonatomic, retain) NSSet *categorysLogs;

    //    - (void)addCategorysLogsObject:(LogRecord *)value;
    //    - (void)removeCategorysLogsObject:(LogRecord *)value;
    //    - (void)addCategorysLogs:(NSSet *)values;
    //    - (void)removeCategorysLogs:(NSSet *)values;


    class func addNewTrackingCategory(title title:NSString, totalValue:NSNumber, color:UIColor)->(TrackingCategory){

        let cat = NSEntityDescription.insertNewObjectForEntityForName("BaseCategory", inManagedObjectContext: getMOC()) as! TrackingCategory

        cat.title = title as String
        cat.totalValue = totalValue
        cat.color = color
        cat.indexNumber = returnListOfCategories().count
        cat.timerIsHidden = 0

        let err = NSErrorPointer()
        do {
            try getMOC().save()
        } catch let error as NSError {
            err.memory = error
        }

        if err != nil {print("Error \(err)");}

        return cat

    }

    class func delTrackingCategory(obj obj:NSManagedObject){

        let err = NSErrorPointer()

        getMOC().deleteObject(obj)
        do {
            try getMOC().save()
        } catch let error as NSError {
            err.memory = error
        }

        if err != nil {print("Error \(err)");}

    }

    class func returnListOfCategories()->NSArray{

        let fetchRequest = NSFetchRequest(entityName: "BaseCategory")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "indexNumber", ascending: true)]

        return (try! getMOC().executeFetchRequest(fetchRequest)) as NSArray

    }

    class func returnListOfTimersMarkedUnhidden()->NSArray{

        let fetchRequest = NSFetchRequest(entityName: "BaseCategory")
        fetchRequest.predicate = NSPredicate(format: "%K == 0", "timerIsHidden")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "indexNumber", ascending: true)]

        return (try! getMOC().executeFetchRequest(fetchRequest)) as NSArray
        
    }

    class func getMOC() -> NSManagedObjectContext{

        let AppDel = UIApplication.sharedApplication().delegate! as! AppDelegate
        return AppDel.managedObjectContext!

    }

    class func sumTotalOfLogRecords(parentCategory parentCategory:TrackingCategory) -> (Double) {

        // for each log record, find out how much time elapsed between checkin and checkout
        // add together

        var totalTime:Double = 0

        for log in parentCategory.categorysLogs{

            let logRecord = log as! LogRecord
            let elapsedT = LogRecordSubclass.findElaspedTime(logRecord: logRecord)

            totalTime = totalTime + elapsedT

        }

        return totalTime
    }

}
