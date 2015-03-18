//
//  PieChartCategoryWrapper.h
//  ProjectTimer
//
//  Created by xcode on 3/18/15.
//  Copyright (c) 2015 MSCline. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PieChartThumbnail, TrackingCategory;

@interface PieChartCategoryWrapper : NSManagedObject

@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) id color;
@property (nonatomic, retain) NSNumber * isHidden;
@property (nonatomic, retain) PieChartThumbnail *catWrappersPieChart;
@property (nonatomic, retain) TrackingCategory *catWrappersBaseCategory;

@end
