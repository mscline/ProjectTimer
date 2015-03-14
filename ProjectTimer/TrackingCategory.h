//
//  TrackingCategory.h
//  ProjectTimer
//
//  Created by xcode on 3/14/15.
//  Copyright (c) 2015 MSCline. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LogRecord, PieChartThumbnail;

@interface TrackingCategory : NSManagedObject

@property (nonatomic, retain) id color;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * totalValue;
@property (nonatomic, retain) NSNumber * indexNumber;
@property (nonatomic, retain) NSSet *categoriesPieCharts;
@property (nonatomic, retain) NSSet *categorysLogs;
@end

@interface TrackingCategory (CoreDataGeneratedAccessors)

- (void)addCategoriesPieChartsObject:(PieChartThumbnail *)value;
- (void)removeCategoriesPieChartsObject:(PieChartThumbnail *)value;
- (void)addCategoriesPieCharts:(NSSet *)values;
- (void)removeCategoriesPieCharts:(NSSet *)values;

- (void)addCategorysLogsObject:(LogRecord *)value;
- (void)removeCategorysLogsObject:(LogRecord *)value;
- (void)addCategorysLogs:(NSSet *)values;
- (void)removeCategorysLogs:(NSSet *)values;

@end
