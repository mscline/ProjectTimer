//
//  MCBlockTouchesView.m
//  ToDo
//
//  Created by xcode on 8/28/14.
//  Copyright (c) 2014 MSCline. All rights reserved.
//

#import "MCBlockTouchesView.h"


@interface MCBlockTouchesView ()

  @property id<MCBlockerView>vcIsMyDelegate;

@end


@implementation MCBlockTouchesView
  @synthesize vcIsMyDelegate;

- (id)initWithDelegate:(id)delegate viewToBlock:(UIView *)blockView
{
    self = [super initWithFrame:CGRectMake(0, 0, blockView.frame.size.width, blockView.frame.size.height)];
    
    if (self) {
        
        [blockView addSubview:self];
        
        [self addGestures];
        
        vcIsMyDelegate = (id)delegate;

    }
    return self;
}


#pragma mark Add Gestures

-(void)addGestures
{
    
    // add Single Tap Gesture
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    singleTapRecognizer.numberOfTapsRequired = 1;
    singleTapRecognizer.delegate = self;
    [self addGestureRecognizer:singleTapRecognizer];
    
    // add Double Tap Gesture
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDougleTap:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.delegate = self;
    [self addGestureRecognizer:doubleTapRecognizer];
    
    // FAILURE REQUIREMENTS
    [singleTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
    
    
    // add Long Tap Gesture
    UILongPressGestureRecognizer *longTapRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongTap:)];
    longTapRecognizer.minimumPressDuration = 1;
    longTapRecognizer.numberOfTouchesRequired = 1;
    longTapRecognizer.numberOfTapsRequired = 0;
    longTapRecognizer.allowableMovement = 20;
    longTapRecognizer.delegate = self;
    [self addGestureRecognizer:longTapRecognizer];
    
    // add Drag Gesture
    // UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panHandler:)];
    // [self addGestureRecognizer:panRecognizer];
    
}


#pragma mark Handle Gestures

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        
        [vcIsMyDelegate blockerViewReceivedTouch];
    
    }
}

- (void)handleDougleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        
        [vcIsMyDelegate blockerViewReceivedTouch];
    
    }
}


-(void)handleLongTap:(UIGestureRecognizer *)sender
{
    
    if (sender.state == UIGestureRecognizerStateBegan)
    {

        [vcIsMyDelegate blockerViewReceivedTouch];
    
    }
    
}




@end
