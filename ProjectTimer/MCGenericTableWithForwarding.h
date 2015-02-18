//
//  MCTableViewForCustomization.h
//  ToDo
//
//  Created by xcode on 1/27/15.
//  Copyright (c) 2015 MSCline. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCTableWithGestures.h"

@interface MCGenericTableWithForwarding : MCTableWithGestures


  // the user will define who they want to be the delegate (eg, their view controller)
  // save that info here
  // in truth, MCTable is its own delegate
  // it will intercept the commands, then use forwarding to pass them along

  @property id tvDataSource;
  @property id tvDelegate;

  -(void)setDelegateSwiftHack:(id)vc;
  -(void)setDataSourceSwiftHack:(id)vc;  // in swift, you can't ever have an AnyObject conform to a protocol
// understandable in theory, but annoying in practice

@end
