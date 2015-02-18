//
//  MCBlockTouchesView.h
//  ToDo
//
//  Created by xcode on 8/28/14.
//  Copyright (c) 2014 MSCline. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol MCBlockerView <NSObject>

  -(void)blockerViewReceivedTouch;

@end


@interface MCBlockTouchesView : UIView <UIGestureRecognizerDelegate>


  - (id)initWithDelegate:(id)delegate viewToBlock:(UIView *)blockView;


@end
