//
//  MCTableViewForCustomization.m
//  ToDo
//
//  Created by xcode on 1/27/15.
//  Copyright (c) 2015 MSCline. All rights reserved.
//

#import "MCGenericTableWithForwarding.h"


@interface MCGenericTableWithForwarding()

@end


@implementation MCGenericTableWithForwarding
  @synthesize tvDataSource, tvDelegate;


#pragma mark SETTING UP DELEGATES AND DATASOURCE

-(void)setDelegate:(id<UITableViewDelegate>)delegate
{

    // MCTable will be its own delegate so that it can itercept the commands
    // then it will forward them to the tvDelegate defined by the user

    // save the forwarding address
    // and then set the tableView's delegate to self
    // when the tableview delegate is set, Apple will check to see what protocol methods are available running respondsToSelector on each
    // thus, the forwarding address must already exist, or the method will respond false

    // note: whether we are in Storyboard or in code, the delegate will be set after the object is created

    // save the forwarding address (ie your view controller)
    tvDelegate = delegate;

    // save the delegate (ie this class)
    [super setDelegate:(id<UITableViewDelegate>)self];
    [super setDataSource:(id<UITableViewDataSource>)self];

}

-(void)setDataSource:(id<UITableViewDataSource>)dataSource
{
    tvDataSource = dataSource;   // keep in this order
    
    [super setDataSource:(id<UITableViewDataSource>)self];
    [super setDelegate:(id<UITableViewDelegate>)self];
}

-(void)setDelegateSwiftHack:(id)vc
{
    self.delegate = vc;
}

-(void)setDataSourceSwiftHack:(id)vc
{
    self.dataSource = vc;
}


#pragma mark FORWARDING

- (id)forwardingTargetForSelector:(SEL)sel
{
    if ([tvDataSource respondsToSelector:sel]) {

        return tvDataSource;

    }else if ([tvDelegate respondsToSelector:sel]) {

        return tvDelegate;

    }

    NSLog(@"Please check to see if you set the delegate.");
    return nil;

}

// allow outside classes to check to see if this class responds to a selector
- (BOOL)respondsToSelector:(SEL)aSelector
{
    // APPLE WILL CALL THIS AS SOON AS THE DELEGATE IS SET
    // IT WILL RUN THIS AND THEN IT WILL CACHE THE RESULTS

    // THUS, IT IS NEC TO DO ALL YOUR RELEVANT SETUP BEFORE SETTING THE DELEGATE


    //NSLog(@"\n\n %s \n\n", sel_getName(aSelector));


    // check to see if this class can handle the message
    if( [super respondsToSelector:aSelector]      ||
       [tvDelegate respondsToSelector:aSelector] ||
       [tvDataSource respondsToSelector:aSelector]   ){

        return true;

    }else{

        return false;

    }

}




//
// FOR FUTURE REF: To allow posing as a class
// http://www.informit.com/articles/article.aspx?p=1765122&seqNum=13
//


@end
