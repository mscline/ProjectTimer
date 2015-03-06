//
//  TabBarController.swift
//  ProjectTimer
//
//  Created by xcode on 3/3/15.
//  Copyright (c) 2015 MSCline. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {


        // constants
        let colors:NSArray = [UIColor.blueColor(), UIColor.redColor(), UIColor.greenColor(), UIColor.purpleColor(), UIColor.orangeColor(), UIColor.yellowColor(), UIColor.brownColor(), UIColor.cyanColor(), UIColor.magentaColor()]
        let colorNames:NSArray = ["Blue", "Red", "Green", "Purple", "Orange", "YellowColor", "BrownColor", "CyanColor","MagentaColor"]  // I don't know of a method to get it and rather than creating a lookup dict, lets go with quick and dirty


    override func viewDidLoad() {
        super.viewDidLoad()

        passColorsToChildViewControllers()

    }

    func passColorsToChildViewControllers(){

        for nav in self.childViewControllers {

            let navC = nav as UINavigationController
            let vc = navC.viewControllers[0] as UIViewController

            if vc.isKindOfClass(StatsViewController){

                let ourVC = vc as StatsViewController
                ourVC.colors = colors

            }

            if vc.isKindOfClass(TimerViewController){

                let ourVC = vc as TimerViewController
                ourVC.colors = colors
                ourVC.colorNames = colorNames
                
            }
        }

    }

}
