//
//  MCAlertWithTextEntry.m
//  igram
//
//  Created by xcode on 12/30/14.
//  Copyright (c) 2014 MSCline. All rights reserved.
//

#import "MCAlertWithTextEntry.h"


UITextField *alertViewPointerToTextView;

@implementation MCAlertWithTextEntry

+(void)presentAlertWithTextEntry_alertViewTitle:(NSString *)title forViewController:(UIViewController *)vc completionBlock:(void(^)(NSString *text))completionBlock
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleAlert];

    // add text field in alert and save pointer to alert text field
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {

        alertViewPointerToTextView = textField;

    }];


    // add save and cancel buttons
    [alert addAction: [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction * action) {

                                                 completionBlock(alertViewPointerToTextView.text);

                                             }]];
    
    [alert addAction: [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    // present alert
    [vc presentViewController:alert animated:YES completion:nil];
    
}

@end
