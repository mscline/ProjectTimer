//
//  EditChartViewController.swift
//  ProjectTimer
//
//  Created by xcode on 3/5/15.
//  Copyright (c) 2015 MSCline. All rights reserved.
//

import UIKit

class EditChartViewController: UIViewController {


        var listOfAllCategories:NSArray?


    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        listOfAllCategories = PieChartThumbnailSubclass.getPieCharts()

    }

    


}
