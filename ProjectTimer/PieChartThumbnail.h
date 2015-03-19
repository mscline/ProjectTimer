//
//  PieChartThumbnail.h
//  ProjectTimer
//
//  Created by xcode on 3/19/15.
//  Copyright (c) 2015 MSCline. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PieChartCategoryWrapper;

@interface PieChartThumbnail : NSManagedObject

@property (nonatomic, retain) NSString * chartTitle;
@property (nonatomic, retain) NSNumber * indexNumber;
@property (nonatomic, retain) NSNumber * isSelected;
@property (nonatomic, retain) id snapshot;
@property (nonatomic, retain) NSSet *pieChartsCategoryWrappers;
@end

@interface PieChartThumbnail (CoreDataGeneratedAccessors)

- (void)addPieChartsCategoryWrappersObject:(PieChartCategoryWrapper *)value;
- (void)removePieChartsCategoryWrappersObject:(PieChartCategoryWrapper *)value;
- (void)addPieChartsCategoryWrappers:(NSSet *)values;
- (void)removePieChartsCategoryWrappers:(NSSet *)values;

@end
