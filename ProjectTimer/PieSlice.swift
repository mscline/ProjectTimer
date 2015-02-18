//
//  PieSlice.swift
//  PieChart
//
//  Created by xcode on 1/21/15.
//  Copyright (c) 2015 MSCline. All rights reserved.
//

import UIKit

class PieSlice: NSObject {

        // INSTANCE VARIABLES

        var titleForLegend:NSString!
        var theTotal:NSNumber!

        var colorOfPieSlice:UIColor!
        var indexNumberTellingOrderToDisplayPiePieces:NSInteger!

        var pointerToDataObjectIfDesired:AnyObject?

    
    init(titleForLegend:NSString, colorOfPieSlice:UIColor, positionOfPieSlice_indexNumber:NSInteger, theTotal:NSNumber) {

        self.titleForLegend = titleForLegend ?? ""
        self.colorOfPieSlice = colorOfPieSlice ?? UIColor.blueColor()
        self.indexNumberTellingOrderToDisplayPiePieces = positionOfPieSlice_indexNumber ?? 0
        self.theTotal = theTotal ?? 0

    }

}
