//
//  PieChartsViewController.swift
//  ProjectTimer
//
//  Created by xcode on 3/4/15.
//  Copyright (c) 2015 MSCline. All rights reserved.
//

import UIKit

class PieChartsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    var listOfPieCharts:NSArray?  // rem: working with CoreData which is in ObjC
    
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        listOfPieCharts = PieChartThumbnailSubclass.getPieCharts()

    }

    // MARK: BUTTON PRESSES

    @IBAction func onAddButtonPressed(sender: AnyObject) {

        addNewChartPart1_askUserForTitle()

    }

    @IBAction func onDeleteButtonPressed(sender: AnyObject) {


    }

    // CRUD

    func addNewChartPart1_askUserForTitle() {


        MCAlertWithTextEntry.presentAlertWithTextEntry_alertViewTitle("What would you like to name your new Pie Chart?", forViewController: self) { (userEnteredText) -> Void in

            self.addNewChartPart2_createNewChartAndReload(title:userEnteredText)

        }

    }

    func addNewChartPart2_createNewChartAndReload(#title:NSString){

        PieChartThumbnailSubclass.addPieChart(title: title)

        listOfPieCharts = PieChartThumbnailSubclass.getPieCharts()
        collectionView.reloadData()
        
    }


    // MARK: COLLECTION VIEW DATA SOURCE

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {

        return 1

    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if listOfPieCharts == nil {return 0;}

        return listOfPieCharts!.count

    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("pieCharts", forIndexPath: indexPath) as ChartCollectionViewCell

        cell.backgroundColor = UIColor.redColor()
       // updateCell(cell: cell, indexPath:indexPath)
        return cell

    }

    func updateCell(#cell:TimerCollectionViewCell, indexPath:NSIndexPath){


    }

    // MARK: COLLECTION VIEW DELEGATE

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        
    }
    


}
