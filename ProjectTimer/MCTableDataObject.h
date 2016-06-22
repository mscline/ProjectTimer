//
//  MCTableDataObject.h
//  ToDo
//
//  Created by xcode on 1/23/15.
//  Copyright (c) 2015 MSCline. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {none, isHighlighted, slowlyFade} HighlightingForDrag;


@interface MCTableDataObject : NSObject

@property NSString *title;
@property NSString *subtitle;

// if you are just using this as a wrapper, then here is a convenient place
// to store a pointer to the original object
@property id wrappedObject;

// required (do not need to set)
@property NSNumber * isSelected;
@property int isHighlightForDrag;
@property NSNumber * sortPosition;  // check???

@end
