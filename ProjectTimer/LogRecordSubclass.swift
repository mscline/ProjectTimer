//
//  LogRecordSubclass.swift
//  ProjectTimer
//
//  Created by xcode on 2/17/15.
//  Copyright (c) 2015 MSCline. All rights reserved.
//

import UIKit

class LogRecordSubclass: LogRecord {

    // from super

    //    @property (nonatomic, retain) NSDate * checkinTime;
    //    @property (nonatomic, retain) NSDate * checkoutTime;
    //    @property (nonatomic, retain) NSString * notes;
    //    @property (nonatomic, retain) TrackingCategory *logRecordsCategory;

    class func addNewLogRecord(#checkinTime:NSDate, parentCategory:TrackingCategorySubclass) -> LogRecordSubclass {

        let log = NSEntityDescription.insertNewObjectForEntityForName("LogRecord", inManagedObjectContext: getMOC()) as LogRecordSubclass

        log.checkinTime = checkinTime
        log.logRecordsCategory = parentCategory

        // save
        var err = NSErrorPointer()
        getMOC().save(err)

        return log

    }

    class func updateLastLogUponCheckout(#record:LogRecordSubclass){

        record.checkoutTime = NSDate()
        var err = NSErrorPointer()
        LogRecordSubclass.getMOC().save(err)
    }

    class func returnLastLog() -> NSArray {

        let err = NSErrorPointer()

        let fetchRequest = NSFetchRequest(entityName: "LogRecord")
        fetchRequest.predicate = NSPredicate(format: "%K == NULL", "checkoutTime")
        return getMOC().executeFetchRequest(fetchRequest, error: err)! as NSArray

    }

    class func getMOC() -> NSManagedObjectContext{

        let AppDel = UIApplication.sharedApplication().delegate! as AppDelegate
        return AppDel.managedObjectContext!

    }

}
