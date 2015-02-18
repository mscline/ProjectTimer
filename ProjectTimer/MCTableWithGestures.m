//
//  MCTableViewWithGestures.m
//  ToDo
//
//  Created by xcode on 8/28/14.
//  Copyright (c) 2014 MSCline. All rights reserved.
//

#import "MCTableWithGestures.h"

@implementation MCTableWithGestures
  @synthesize delegateForTableViewWithGestures;

- (id)init
{
    self = [super init];
    
    if (self) {
        
        [self addGestures];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
         [self addGestures];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    if (self) {

        [self addGestures];
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
        [self notifyParentThatSubviewRecievedGesture:singleTap recognizer:sender];
    }
}

- (void)handleDougleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        [self notifyParentThatSubviewRecievedGesture:doubleTap recognizer:sender];
    }
}


-(void)handleLongTap:(UIGestureRecognizer *)sender
{
    
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        [self notifyParentThatSubviewRecievedGesture:longTap recognizer:sender];
    }
    
}

-(void)notifyParentThatSubviewRecievedGesture:(gesture)gestureType recognizer:(UIGestureRecognizer *)sender
{

    BOOL touchWasOnTopHalf = 0;

    // find the index path and corresponding cell
    CGPoint xyPosition = [sender locationInView:self];
    NSIndexPath *indexPath = [self indexPathForRowAtPoint:xyPosition];
    NSInteger rowNumber = indexPath.row;
    UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];

    if(cell){
    
        // was the touch on the top or bottom half of the cell (for drop)
        CGPoint xyPositionLocal = [sender locationInView:cell];

        if(xyPositionLocal.y < cell.frame.size.height/2){

            touchWasOnTopHalf = TRUE;
            
        }

    }

   [delegateForTableViewWithGestures tableReceivedTouchAtIndex:rowNumber
                                     gesture:gestureType
                           touchWasOnTopHalf:touchWasOnTopHalf
                             cellTouched:cell];
    
}


@end
