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



// CREATING A NEW TABLE
// opt A: do it programatically
//
// opt B: do it in storyboard and change the class to MCTable
// if using a prototype cell, you will need to set identifier = @"tableID"


// DO NOT USE CELL FOR ROW AT INDEX PATH
// it is reserved
// use tableView:willDisplayCell: to intercept the cell before it is displayed
// if you want to use a customized tableviewcell, create a prototype cell
// programmatically add IBOutlets if unable to drag and drop


// TO PROVIDE DATA FOR YOUR TABLE
//
// opt A: set the arrayOfDataForDisplay (then just call reloadData)
// don't forget to set the delegate and dataSource delegates
// even if not using delegate methods, setting them is required
//
// opt B: you can use your traditional table view data source/delegate methods
// the disadvantage of this method is that you will need to resort your
// data after a drag and drop (MCTable doesn't have access to the array,
// so it can't)
// the table view will notify you when a change was made


// UPDATING OBJECT POSITIONING
//
// opt A: implement tableView_dataObjectForIndexPath protocol
// it is necessary to provide the data object in the MCTableDataObject
// because the object will need to record whether it has a checkmark
// and where it is positioned
//
// opt B: implement the tableView_dataObjects_orderDidChange protocol method
// the best way to way to save checkmark or position directly data source
// is to subclass your data object and override the getters and setters


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


