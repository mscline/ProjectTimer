//
//  LogRecord.h
//  ProjectTimer
//
//  Created by xcode on 2/17/15.
//  Copyright (c) 2015 MSCline. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TrackingCategory;

@interface LogRecord : NSManagedObject

@property (nonatomic, retain) NSDate * checkinTime;
@property (nonatomic, retain) NSDate * checkoutTime;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) TrackingCategory *logRecordsCategory;

@end
