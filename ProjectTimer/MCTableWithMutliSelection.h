//
//  MCTable.h
//  ToDo
//
//  Created by xcode on 1/21/15.
//  Copyright (c) 2015 MSCline. All rights reserved.
//

#import "MCTableWithGestures.h"
#import "MCGenericTableWithForwarding.h"
#import "MCTableDataObject.h"


// to provide data for the table
// you can use your table view data source methods
// or conversely, you can set the arrayOfDataForDisplay
// don't forget to set the delegate and dataSource delegates, however
// even if not using delegate methods, setting them is required 

// if using a prototype cell, you will need to set identifier = @"tableID"
// if you set the arrayOfDataForDisplay with a prototype cell
// you can drag in visual elements, or even a button
// but your cell cannot have custom properties or methods
// in order to intercept the cell before it is displayed, use tableView:willDisplayCell:

// whereas, if you want to use it as an traditional table view
// use the basic tableView delegate methods
// then implement tableView_dataObjectForIndexPath protocol
// it is necessary to provide the data object in the MCTableDataObject
// because the object will need to record whether it has a checkmark
// and where it is positioned
// the disadvantage of this method is that you will need to resort your
// data after a drag and drop (MCTable doesn't have access to the array,
// so it can't)

// if you want to save the checkmark or position directly to your db
// subclass your data object and override the getters and setters

// SWIFT ONLY: NEED TO SET DELEGATES USING SETTER METHODS BELOW  (GRRR...)
//-(void)setDelegateSwiftHack:(id)vc;
//-(void)setDataSourceSwiftHack:(id)vc;


@protocol MCTable_DataItemProtocol <NSObject>

  @optional
  -(MCTableDataObject *)tableView_dataObjectForIndexPath:(NSIndexPath *)indexPath;
  -(void)tableView_dataObjects_orderDidChange;

@end


@interface MCTableWithMutliSelection : MCGenericTableWithForwarding

  @property NSMutableArray *arrayOfDataForDisplay;
  @property UIFont *fontTitle;      // still need to test
  @property UIFont *fontSubTitle;

  // other
  @property UIColor *color_selectCellForDrag;
  @property UIColor *color_cellDefault;

  @property BOOL animationSequenceOnLoadActive;

  -(instancetype)initWithFrame:(CGRect)frame cancelDropWhenTouchOutsideTableAndWithInThisView:(UIView *)blockInFrontOfThisView;


@end

// initWithCoder is called when generate something from storyboard
// cannot access delegate and datasource
// table will reload as soon as you add it using [view addSubview:]
// since table view will load before your view controllers viewDidLoad, can't put local vars in there


