//
//  DataItem.swift
//  PieChart
//
//  Created by xcode on 2/11/15.
//  Copyright (c) 2015 MSCline. All rights reserved.
//

import UIKit

class DataItem: NSObject {

        var title:NSString?
        var color:UIColor?
        var amount:Int?

    init(title:NSString?, color:UIColor?, amount:Int?){

        self.title = title ?? ""
        self.color = color ?? UIColor.whiteColor()
        self.amount = amount ?? 0

    }
}
