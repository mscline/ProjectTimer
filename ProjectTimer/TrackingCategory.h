//
//  TrackingCategory.h
//  ProjectTimer
//
//  Created by xcode on 3/25/15.
//  Copyright (c) 2015 MSCline. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LogRecord, PieChartCategoryWrapper;

@interface TrackingCategory : NSManagedObject

@property (nonatomic, retain) id color;
@property (nonatomic, retain) NSNumber * indexNumber;
@property (nonatomic, retain) NSNumber * timerIsHidden;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * totalValue;
@property (nonatomic, retain) NSSet *baseCategorysWrappers;
@property (nonatomic, retain) NSSet *categorysLogs;
@end

@interface TrackingCategory (CoreDataGeneratedAccessors)

- (void)addBaseCategorysWrappersObject:(PieChartCategoryWrapper *)value;
- (void)removeBaseCategorysWrappersObject:(PieChartCategoryWrapper *)value;
- (void)addBaseCategorysWrappers:(NSSet *)values;
- (void)removeBaseCategorysWrappers:(NSSet *)values;

- (void)addCategorysLogsObject:(LogRecord *)value;
- (void)removeCategorysLogsObject:(LogRecord *)value;
- (void)addCategorysLogs:(NSSet *)values;
- (void)removeCategorysLogs:(NSSet *)values;

@end
