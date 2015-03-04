//
//  MCAlertWithTextEntry.h
//  igram
//
//  Created by xcode on 12/30/14.
//  Copyright (c) 2014 MSCline. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCAlertWithTextEntry : NSObject

  +(void)presentAlertWithTextEntry_alertViewTitle:(NSString *)title forViewController:(UIViewController *)vc completionBlock:(void(^)(NSString *text))completionBlock;

@end
