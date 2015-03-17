//
//  PieChartThumbnail.h
//  ProjectTimer
//
//  Created by xcode on 3/17/15.
//  Copyright (c) 2015 MSCline. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TrackingCategory;

@interface PieChartThumbnail : NSManagedObject

@property (nonatomic, retain) NSString * chartTitle;
@property (nonatomic, retain) NSNumber * indexNumber;
@property (nonatomic, retain) NSNumber * isSelected;
@property (nonatomic, retain) id snapshot;
@property (nonatomic, retain) NSSet *chartsCategories;
@end

@interface PieChartThumbnail (CoreDataGeneratedAccessors)

- (void)addChartsCategoriesObject:(TrackingCategory *)value;
- (void)removeChartsCategoriesObject:(TrackingCategory *)value;
- (void)addChartsCategories:(NSSet *)values;
- (void)removeChartsCategories:(NSSet *)values;

@end
