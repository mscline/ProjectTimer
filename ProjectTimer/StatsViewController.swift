//
//  StatsViewController.swift
//  ProjectTimer
//
//  Created by xcode on 3/5/15.
//  Copyright (c) 2015 MSCline. All rights reserved.
//

import UIKit

class StatsViewController: ChartAndLegendVC_Superclass {


        var selectedPieChart:PieChartThumbnail?

        @IBOutlet weak var defaultViewToShowIfNoData: UIView!


    override func viewWillAppear(animated: Bool) {

        defaultViewToShowIfNoData.hidden = true
        self.navigationItem.title = selectedPieChart?.chartTitle ?? "Statistics"

        super.viewWillAppear(animated)

    }

    override func getThePieChartCategoriesYouWantToDisplay_OverrideHereIfSubclassing() -> (NSSet) {

        // get the selected pie chart and grab its categories
        selectedPieChart = PieChartThumbnailSubclass.getTheSelectedPieChart()

        if selectedPieChart == nil || selectedPieChart!.chartsCategories == nil { return NSSet()}

        let categories = selectedPieChart!.chartsCategories as NSSet

        return categories
        
    }

    override func noDataToDispalyInChart(){

        // if no data to display, can customize view here
        defaultViewToShowIfNoData.hidden = false

    }


    // TODO change chart title
    // if have chart but no items, need different message

}
