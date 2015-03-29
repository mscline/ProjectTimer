//
//  MCTable.m
//  ToDo
//
//  Created by xcode on 1/21/15.
//  Copyright (c) 2015 MSCline. All rights reserved.
//

#import "MCTableWithMutliSelection.h"
#import "MCBlockTouchesView.h"
#import "MCTableDataObject.h"


typedef enum {none, isHighlighted, slowlyFade} HighlightingForDrag;


@interface MCTableWithMutliSelection () <UITableViewDataSource, UITableViewDelegate, MCTableCellTouched, MCBlockerView>


  // drag and drop
  @property BOOL moveCellInProgress;
  @property MCBlockTouchesView *blocker;
  @property NSString *dropDirections;


@end


@implementation MCTableWithMutliSelection
  @synthesize arrayOfDataForDisplay, moveCellInProgress, blocker, animationSequenceOnLoadActive, fontTitle, fontSubTitle, color_cellDefault, color_selectCellForDrag;


#pragma mark INIT AND BASIC SETUP

-(instancetype)initWithFrame:(CGRect)frame cancelDropWhenTouchOutsideTableAndWithInThisView:(UIView *)blockInFrontOfThisView
{
    self = [super initWithFrame:frame];

    if(self){

        [self setup_blockInFrontOfView:blockInFrontOfThisView];
        [self setup_misc];

    }
    
    return self;
    
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    if(self){

        [self setup_blockInFrontOfView:nil ];
        [self setup_misc];
    }
    
    return self;
    
}

-(void)setup_blockInFrontOfView:(UIView *)view
{

    [self setupDelegates];
    [self setupBlockerView:view];
    [self setDefaultSettings];

}

-(void)setup_misc
{

    self.dropDirections = @"Double Click To Drop";

}

-(void)setupDelegates
{
    // the tap gestures will also be received by this class
    self.delegateForTableViewWithGestures = self;

    // the other delegates are set by the setter methods in the superclass
}

-(void)setDefaultSettings
{
    if(!color_cellDefault){ color_cellDefault = [UIColor clearColor];}
    if(!color_selectCellForDrag){ color_selectCellForDrag = [UIColor redColor];}
}

-(void)setupBlockerView:(UIView *)blockInFrontOfView
{

    blocker =[[MCBlockTouchesView alloc]initWithDelegate:self viewToBlock:blockInFrontOfView];
    blocker.hidden = true;
    
}


#pragma mark INVALIDATE OLD INITS

-(instancetype)init
{
    self = [super init];

    if(self){

        abort();

    }

    return self;

}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if(self){

        abort();

    }
    
    return self;
    
}


#pragma mark TABLEVIEW - CELL FOR ROW AT INDEX PATH

-(UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell;
    MCTableDataObject *item;

    // if user already provided data, then update cell
    if(arrayOfDataForDisplay){

        cell = [self returnReuseCell_tableView:table];
        cell = [self formatDefaultCell:cell atIndexPath:indexPath];
        item = [self loadDataForCellAndReturnDataObject:cell atIndexPath:indexPath];

    // if user did not provide data, ask user for it
    }else{

        cell = [self.tvDataSource tableView:table cellForRowAtIndexPath:indexPath];
        item = [self getDataObjectFromTVDelegate_indexPath:indexPath];

    }

    [self addCheckmarkAndHighlights:cell dataObject:item];
    [self addLabelWithDragAndDropDirectionsToCellIfDoesNotHave:cell];
    [self runStartUpAnimationSequence:cell forIndexPath:indexPath];  // DO WE WANT HERE???

    return cell;

}

-(UITableViewCell *)returnReuseCell_tableView:(UITableView *)table
{

    // no need different routine if using prototype cell
    UITableViewCell *cell;

    cell = [table dequeueReusableCellWithIdentifier:@"tableID"];

    if(!cell){

        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"tableID"];

    }

    return cell;

}


- (UITableViewCell *)formatDefaultCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{

    if(fontTitle)   { cell.textLabel.font = fontTitle; }
    if(fontSubTitle){ cell.detailTextLabel.font = fontSubTitle; }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = color_cellDefault;
    cell.alpha = .7;

    return cell;
}

- (MCTableDataObject *)loadDataForCellAndReturnDataObject:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{

    MCTableDataObject *item = [arrayOfDataForDisplay objectAtIndex:indexPath.row];

    cell.textLabel.text = item.title;
    cell.detailTextLabel.text = item.subtitle;
    // UPGRADE???   cell.imageView.image = [UIImage imageWithData:???];

    return item;

}

-(MCTableDataObject *)getDataObjectFromTVDelegate_indexPath:(NSIndexPath *)path
{

    if([self.tvDataSource respondsToSelector:@selector(tableView_dataObjectForIndexPath:)]){

        return [self.tvDataSource tableView_dataObjectForIndexPath:path];

    }else{

        NSLog(@"Please implement the tableView_dataObjectForIndexPath protocol method.");
        return nil;
        
    }
}

-(void)addLabelWithDragAndDropDirectionsToCellIfDoesNotHave:(UITableViewCell *)cell
{
    // we didn't create the cell, so we are just going to do a quick insertion

    // set defaults
    UIColor *textColor = color_cellDefault;                         // UPGRADE ????
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:10];  // UPGRADE ????

    CGRect labelFrame = CGRectMake(10, cell.frame.size.height - 10, 200, 10);


    // check to see if cell has the drop directions
    for (id subview in cell.subviews){

        if([subview isKindOfClass:[UILabel class]])
        {
            UILabel *label = (UILabel *)subview;
            if([label.text isEqualToString:self.dropDirections]){ return; }
        }

    }


    // if does not have, add one
    UILabel *label = [[UILabel alloc]initWithFrame:labelFrame];
    label.text = self.dropDirections;
    label.font = font;
    label.textColor = textColor;
    label.hidden = true;
    [cell addSubview:label];

}

- (UITableViewCell *)addCheckmarkAndHighlights:(UITableViewCell *)cell dataObject:(MCTableDataObject *)item
{

    if(!moveCellInProgress){  // a view controller property

        // add checkmark
        if([item.isSelected boolValue]) {

            cell.accessoryType = UITableViewCellAccessoryCheckmark;

        }else{

            cell.accessoryType = UITableViewCellAccessoryNone;

        }

        // make sure drop notification is off
        [self helper_turnDropNotificationOnOrOffForCell:cell shouldDisplay:false];

    }else{

        // if highlighted change background color
        if(item.isHighlightForDrag == isHighlighted) {

            cell.backgroundColor = color_selectCellForDrag;
            [self helper_turnDropNotificationOnOrOffForCell:cell shouldDisplay:true];

        } else if (item.isHighlightForDrag == slowlyFade){

            // something is wrong with the reload
            // and not hitting here
            [UIView animateWithDuration:1.0 animations:^{

                cell.backgroundColor = color_cellDefault;
                [self helper_turnDropNotificationOnOrOffForCell:cell shouldDisplay:false];

            }];

            item.isHighlightForDrag = none;

        } else {  // it is not a not highlighted cell

            cell.accessoryType = UITableViewCellAccessoryNone;
            [self helper_turnDropNotificationOnOrOffForCell:cell shouldDisplay:false];

        }

    }

    return cell;


}

-(void)helper_turnDropNotificationOnOrOffForCell:(UITableViewCell *)cell shouldDisplay:(BOOL)shouldDisplay
{
    // check to see if cell has the drop directions
    // the user created the cell, so we added a subview
    // thus, to change it to hide/unhide it, we need to look for it

    for (id subview in cell.subviews){

        if([subview isKindOfClass:[UILabel class]])
        {
            UILabel *label = (UILabel *)subview;
            if([label.text isEqualToString:self.dropDirections]){

            label.hidden = !shouldDisplay;

            }

        }
        
    }
}


#pragma mark OTHER TABLEVIEW PROTOCOL METHODS

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    if(arrayOfDataForDisplay){

        return [arrayOfDataForDisplay count];

    } else {

        if([self.tvDelegate respondsToSelector:@selector(tableView:numberOfRowsInSection:)]){

            return [self.tvDelegate tableView:self numberOfRowsInSection:section];

        }else{

            return 0;
        };
        
    }
    
}

-(void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    // get data object and tell it to toggle checkmark
    MCTableDataObject *item;

    if(arrayOfDataForDisplay != nil){

        item = [arrayOfDataForDisplay objectAtIndex:indexPath.row];

    }else{

        item = [self getDataObjectFromTVDelegate_indexPath:indexPath];

    }

    item.isSelected = [NSNumber numberWithInt: ([item.isSelected intValue] + 1) % 2];


    // forward message to user
    if([self.tvDelegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]){

        [self.tvDelegate tableView:table didSelectRowAtIndexPath:indexPath];

    }

    
    // reload table rows
    [self reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];

}


#pragma mark MC-TABLE-VIEW-WITH-GESTURE DELEGATES / INITIATE DROP

-(void)tableReceivedTouchAtIndex:(NSInteger)rowNumber gesture:(gesture)gestureType touchWasOnTopHalf:(BOOL)touchWasOnTopHalf cellTouched:(UITableViewCell *)cell
{

    if(gestureType == longTap){

        [self prepareForDrop_receivedTouchAtIndex:rowNumber gesture:gestureType touchWasOnTopHalf:touchWasOnTopHalf cellTouched:cell];

    } else if(gestureType == doubleTap){

        [self drop_receivedTouchAtIndex:rowNumber gesture:doubleTap touchWasOnTopHalf:touchWasOnTopHalf cellTouched:cell];
        [self dropFailed];  // use to turn everything off

    }

}


#pragma mark DROP OBJECT AT INDEX

-(void)prepareForDrop_receivedTouchAtIndex:(NSInteger)rowNumber gesture:(gesture)gestureType touchWasOnTopHalf:(BOOL)touchWasOnTopHalf cellTouched:(UITableViewCell *)cell
{

    moveCellInProgress = TRUE;
    blocker.hidden = FALSE;

    // get data object for selected cell and update it
    MCTableDataObject *item;

    if(arrayOfDataForDisplay != nil){

        item = [arrayOfDataForDisplay objectAtIndex:rowNumber];

    }else{

        NSIndexPath *path = [NSIndexPath indexPathForRow:rowNumber inSection:0];
        item = [self getDataObjectFromTVDelegate_indexPath:path];

    }

    item.isHighlightForDrag = isHighlighted;

    // need to update full table because check marks will be hidden
    [self reloadData];

}

-(void)drop_receivedTouchAtIndex:(NSInteger)rowNumber gesture:(gesture)gestureType touchWasOnTopHalf:(BOOL)touchWasOnTopHalf cellTouched:(UITableViewCell *)cell
{
    // if you click on the bottom of the table, no cell will be return
    // but want to still drop at the end of the list
    if(!cell){

        // insert item at
        rowNumber = arrayOfDataForDisplay.count - 1;

    }

    // MOVE OBJECTS FROM POSITION 1 TO POSITION 2
    // 1) get a copy of the data (just an array with pointers)
    // 2) pull out selected data objects and replace with placeholder

    NSMutableArray *copyOfTagItems = [self getCopyOfDataItems];

    // get selected items
    NSMutableArray *selectedDataObjects = [NSMutableArray new];

    for(int x = 0; x < [copyOfTagItems count]; x++){

        MCTableDataObject *task1 = [copyOfTagItems objectAtIndex:x];

        if(task1.isHighlightForDrag == isHighlighted){

            [selectedDataObjects addObject:task1];
            [copyOfTagItems replaceObjectAtIndex:x withObject:@"placeholder"];

        }


    }

    // 3) insert selected data objects at drop location
    //    since we added placeholders, it is just a simple insertion

    int index = (int)rowNumber;

    if(!touchWasOnTopHalf){ index ++;}
    if(index > [copyOfTagItems count]){ index = (int)[copyOfTagItems count];}

    NSRange range = NSMakeRange(index, [selectedDataObjects count]);
    [copyOfTagItems insertObjects:selectedDataObjects atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];


    // 4) remove placeholders

    NSMutableArray *rawData = [NSMutableArray new];

    for(id obj in copyOfTagItems){

        if(![obj isKindOfClass:[NSString class]]){

            [rawData addObject:(MCTableDataObject *)obj];
        }

    }

    // 5) update the sortPosition field
    
    int x = 0;

    for(MCTableDataObject *obj in rawData){

        obj.sortPosition = [NSNumber numberWithInt:x];
        x++;

    }

    // 6) update table
    
    if(self.arrayOfDataForDisplay){

        self.arrayOfDataForDisplay = rawData;

    }

    // 7) notify parent vc
    if([self.tvDataSource respondsToSelector:@selector(tableView_dataObjects_orderDidChange)]){

            [self.tvDataSource tableView_dataObjects_orderDidChange];

    }

    // 8)  dropFailed called from parent to reset everything

}

-(NSMutableArray *)getCopyOfDataItems
{
    NSMutableArray *data;

    if(arrayOfDataForDisplay){

        data = [NSMutableArray arrayWithArray:arrayOfDataForDisplay];

    } else {

        for(int x = 0; x < [self.tvDataSource tableView:self numberOfRowsInSection:0]; x++){

            NSIndexPath *path = [NSIndexPath indexPathForRow:x inSection:0];
            [data addObject:[self.tvDataSource tableView_dataObjectForIndexPath:path]];
        }
    }

    return data;

}

-(void)dropFailed
{

    moveCellInProgress = FALSE;
    blocker.hidden = TRUE;

    // clear highlighted cells
    for(MCTableDataObject *task in arrayOfDataForDisplay){

        if(task.isHighlightForDrag == isHighlighted){

            task.isHighlightForDrag = slowlyFade;

        }
    }
    
    [self reloadData];

}


#pragma mark BLOCKING VIEW

-(void)blockerViewReceivedTouch
{

    [self dropFailed];

}



#pragma mark ANIMATION SEQUENCE

-(void)runStartUpAnimationSequence:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    if(animationSequenceOnLoadActive && indexPath.row == 0){

        [self cellAnimationSequence:cell];

    };
    
}

-(void)cellAnimationSequence:(UIView *)cell
{

    CATransform3D rotate = CATransform3DMakeRotation(1.57, 0.0, 0.7, 0.4);
    rotate.m34 = -1.666;

    // initial state
    cell.layer.transform = rotate;
    cell.layer.anchorPoint = CGPointMake(0,0.5);
    cell.layer.shadowColor = [[UIColor blackColor] CGColor];
    cell.alpha = 0;

    [UIView beginAnimations:@"rotations" context:NULL];
    [UIView setAnimationDuration:0.8];

    // final state
    cell.layer.transform = CATransform3DIdentity;
    cell.alpha = 1;
    cell.layer.shadowOffset = CGSizeMake(0,0);

    // run it!
    [UIView commitAnimations];
    
}


@end
