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
        var isSelected = true
    
        weak var pointerToParentObject:AnyObject?  // if items are selected, you want a way to figure out corresponding parent objects, rather than using tags (like in UITableView), I am just going allow the user to give the pointer (thus dispensing with the lookup process)
    

    init(title:NSString?, color:UIColor?, amount:Int?, isSelected:Bool!, optional_parentObject:AnyObject?){

        self.title = title ?? ""
        self.color = color ?? UIColor.whiteColor()
        self.amount = amount ?? 0
        self.isSelected = isSelected
        self.pointerToParentObject = optional_parentObject

    }
}
