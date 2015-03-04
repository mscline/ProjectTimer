//
//  PieChart.h
//  ProjectTimer
//
//  Created by xcode on 3/4/15.
//  Copyright (c) 2015 MSCline. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TrackingCategory;

@interface PieChart : NSManagedObject

@property (nonatomic, retain) id snapshot;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *pieChartsCategories;
@end

@interface PieChart (CoreDataGeneratedAccessors)

- (void)addPieChartsCategoriesObject:(TrackingCategory *)value;
- (void)removePieChartsCategoriesObject:(TrackingCategory *)value;
- (void)addPieChartsCategories:(NSSet *)values;
- (void)removePieChartsCategories:(NSSet *)values;

@end
