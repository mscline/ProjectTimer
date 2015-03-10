//
//  Grayscale.h
//  ProjectTimer
//
//  Created by xcode on 3/10/15.
//  Copyright (c) 2015 MSCline. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{ALPHA,BLUE,GREEN,RED} PIXELS;

@interface Grayscale : NSObject

    +(UIImage *)convertToGrayscale_image:(UIImage *)startingImage;

@end
