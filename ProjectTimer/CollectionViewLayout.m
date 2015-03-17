//
//  CollectionViewLayout.m
//  CollectionViewCircle
//
//  Created by xcode on 12/3/14.
//  Copyright (c) 2014 MSCline. All rights reserved.
//

#import "CollectionViewLayout.h"

@interface CollectionViewLayout()

  @property NSMutableArray *storageArray;

  @property float radius;
  @property float divideCircleInXPieces;
  @property float angle;

  @property CGSize cellSize;
  @property CGPoint center;

@end

@implementation CollectionViewLayout
  @synthesize angle, storageArray, radius, center, divideCircleInXPieces, cellSize;

// to link:
// opt A:
// storyboard: change the Layout option from Flow to Custom
// then in code:
//       [collectionView setCollectionViewLayout:animated:completion:
// opt B:
// just set collectionView.collectionViewLayout = [MyCustomLayout new];

// use invalidateLayout if want collection view to recompute layout


-(void)prepareLayout
{

    storageArray = [NSMutableArray new];

    // calc cell size
    cellSize = CGSizeMake(125.0, 125.0);

    // get number of elements
    divideCircleInXPieces = [self.collectionView numberOfItemsInSection:0];

    // set radius of cv
    if(self.collectionView.frame.size.height > self.collectionView.frame.size.width){

        radius = (self.collectionView.frame.size.width / 2 - cellSize.width/2 );

    }else{

        radius = (self.collectionView.frame.size.height / 2 - cellSize.height/2);

    }


    // get center
    center = CGPointMake(self.collectionView.frame.size.width/2, self.collectionView.frame.size.height/2);

    // calc angle, what angle should the center of the next element be at
    angle =  2 * M_PI / divideCircleInXPieces;
    
    
}

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{

    // for each element position
    // create UICollectionViewLayoutAttribute and set:
    //      .center
    //      .size
    //      .zIndex

    // wrap in Array and return an array of UICollectionViewAttributes
    //      note: UICollectionViewLayout has a collectionView property
    //      and in turn, the collectionView has a dataSource property


    for(int i = 0; i < [self.collectionView numberOfItemsInSection:0]; i++){

        [storageArray addObject:[self buildAttributeForIndex:i]];
    }

    return storageArray;

}


-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{

    // Your layout object must be prepared to provide the layout attributes for each cell, supplementary view, and decoration view it supports.
    return [self buildAttributeForIndex:indexPath.row];

}

-(UICollectionViewLayoutAttributes *)buildAttributeForIndex:(int)i
{

    UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
    attr.size = cellSize;
    attr.center = CGPointMake(center.x - radius * cosf(i * angle) ,
                              center.y - radius * sinf(i * angle) );
    attr.zIndex = 0;

    return attr;
}

//-(CGSize)collectionViewContentSize
//{
//   // let super handle
//}


//If you want to create an interactive transition—one that is driven by a gesture recognizer or touch events—use the startInteractiveTransitionToCollectionViewLayout:completion: method to change the layout object. That method installs an intermediate layout object whose purpose is to work with your gesture recognizer or event-handling code to track the transition progress. When your event-handling code determines that the transition is finished, it calls the finishInteractiveTransition or cancelInteractiveTransition method to remove the intermediate layout object and install the intended target layout object.


@end
