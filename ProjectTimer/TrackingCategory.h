//
//  TrackingCategory.h
//  ProjectTimer
//
//  Created by xcode on 2/17/15.
//  Copyright (c) 2015 MSCline. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LogRecord;

@interface TrackingCategory : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * totalValue;
@property (nonatomic, retain) id color;
@property (nonatomic, retain) NSSet *categorysLogs;
@end

@interface TrackingCategory (CoreDataGeneratedAccessors)

- (void)addCategorysLogsObject:(LogRecord *)value;
- (void)removeCategorysLogsObject:(LogRecord *)value;
- (void)addCategorysLogs:(NSSet *)values;
- (void)removeCategorysLogs:(NSSet *)values;

@end
