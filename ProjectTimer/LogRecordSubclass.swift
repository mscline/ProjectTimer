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

    class func addNewLogRecord(checkinTime checkinTime:NSDate, parentCategory:TrackingCategory) -> LogRecord {

        let log = NSEntityDescription.insertNewObjectForEntityForName("LogRecord", inManagedObjectContext: getMOC()) as! LogRecord

        log.checkinTime = checkinTime
        log.logRecordsCategory = parentCategory

        // save
        let err = NSErrorPointer()
        do {
            try getMOC().save()
        } catch let error as NSError {
            err.memory = error
        }

        return log

    }

    class func updateLastLogUponCheckout(record record:LogRecord){

        record.checkoutTime = NSDate()
        let err = NSErrorPointer()
        do {
            try LogRecordSubclass.getMOC().save()
        } catch let error as NSError {
            err.memory = error
        }
        
    }

    class func returnLastLog() -> NSArray {

        _ = NSErrorPointer()

        let fetchRequest = NSFetchRequest(entityName: "LogRecord")
        fetchRequest.predicate = NSPredicate(format: "%K == NULL", "checkoutTime")
        return (try! getMOC().executeFetchRequest(fetchRequest)) as NSArray

    }

    class func findElaspedTime(logRecord logRecord:LogRecord)->(Double){

        let checkoutT = logRecord.checkoutTime ?? NSDate()  // if haven't checked out use current date
        let elapsedTime = checkoutT.timeIntervalSinceReferenceDate - logRecord.checkinTime.timeIntervalSinceReferenceDate

        return elapsedTime

    }

    class func delLogRecord(obj obj:NSManagedObject){

        let err = NSErrorPointer()

        getMOC().deleteObject(obj)
        do {
            try getMOC().save()
        } catch let error as NSError {
            err.memory = error
        }

        if err != nil {print("Error \(err)");}
        
    }

    class func getMOC() -> NSManagedObjectContext{

        let AppDel = UIApplication.sharedApplication().delegate! as! AppDelegate
        return AppDel.managedObjectContext!

    }

}
