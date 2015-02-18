//
//  TrackingCategorySubclass.swift
//  ProjectTimer
//
//  Created by xcode on 2/17/15.
//  Copyright (c) 2015 MSCline. All rights reserved.
//

import UIKit

class TrackingCategorySubclass: TrackingCategory {

    // from superclass

    //    @property (nonatomic, retain) NSString * title;
    //    @property (nonatomic, retain) NSNumber * totalValue;
    //    @property (nonatomic, retain) id color;
    //    @property (nonatomic, retain) NSSet *categorysLogs;

    //    - (void)addCategorysLogsObject:(LogRecord *)value;
    //    - (void)removeCategorysLogsObject:(LogRecord *)value;
    //    - (void)addCategorysLogs:(NSSet *)values;
    //    - (void)removeCategorysLogs:(NSSet *)values;


    // ????
//          lazy var MOC:NSManagedObjectContext? = {
//
//                return TrackingCategorySubclass.getMOC()
//            }()


    class func addNewTrackingCategory(#title:NSString, totalValue:NSNumber, color:UIColor){

        let cat = NSEntityDescription.insertNewObjectForEntityForName("TrackingCategory", inManagedObjectContext: getMOC()) as TrackingCategory

        cat.title = title
        cat.totalValue = totalValue
        cat.color = color

        var err = NSErrorPointer()
        getMOC().save(err)

        if err != nil { println(err) ;}
    }

    class func delTrackingCategory(#obj:NSManagedObject){

        let err = NSErrorPointer()

        getMOC().deleteObject(obj)
        getMOC().save(err)

    }

    class func returnListOfCategories()->NSArray{

        let fetchRequest = NSFetchRequest(entityName: "TrackingCategory")

        var err = NSErrorPointer()
        return getMOC().executeFetchRequest(fetchRequest, error: err)! as NSArray

    }

    class func getMOC() -> NSManagedObjectContext{

        let AppDel = UIApplication.sharedApplication().delegate! as AppDelegate
        return AppDel.managedObjectContext!

    }

}
