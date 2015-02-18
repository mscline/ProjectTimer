//
//  MCTableViewWithGestures.h
//  ToDo
//
//  Created by xcode on 8/28/14.
//  Copyright (c) 2014 MSCline. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {singleTap, doubleTap, longTap, dragStart, dragMove, dragEnd, iconPressedAndCommandSentToDataSourceDelegate} gesture;


@protocol MCTableCellTouched <NSObject>

  -(void)tableReceivedTouchAtIndex:(NSInteger)rowNumber
                              gesture:(gesture)gestureType
                    touchWasOnTopHalf:(BOOL)touchWasOnTopHalf
                          cellTouched:(UITableViewCell *)cell;

@end


@interface MCTableWithGestures : UITableView <UIGestureRecognizerDelegate>

  @property id <MCTableCellTouched> delegateForTableViewWithGestures;

@end

