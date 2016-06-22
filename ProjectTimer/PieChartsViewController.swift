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
        var selectedPieChart = PieChartThumbnailSubclass.getTheSelectedPieChart()

        // colors and alpha
        let alphaForNonSelectedItems:CGFloat = 0.7
        let color_selected = UIColor(red: 255/255.0, green: 255/255.0, blue: 102/255.0, alpha: 0.65)
        let color_unselected = UIColor.grayColor()//(red: 100/255.0, green: 100/255.0, blue: 50/255.0, alpha: 1.0)
        var colors:NSArray?  // will pass to Edit VC

        @IBOutlet weak var collectionView: UICollectionView!


    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        listOfPieCharts = PieChartThumbnailSubclass.getPieCharts()
        selectedPieChart = PieChartThumbnailSubclass.getTheSelectedPieChart()
        disableEditButtonIfNoItems()
        collectionView.reloadData()

    }

    func disableEditButtonIfNoItems(){


        if selectedPieChart != nil {

            self.navigationItem.rightBarButtonItem?.enabled = true

        } else {

            self.navigationItem.rightBarButtonItem?.enabled = false
            
        }

    }

    // MARK: BUTTON PRESSES

    @IBAction func onAddButtonPressed(sender: AnyObject) {

        addNewChartPart1_askUserForTitle()

    }

    @IBAction func onEditButtonPressed(sender: AnyObject) {

        self.performSegueWithIdentifier("toEditor", sender: sender)

    }



    // CRUD

    func addNewChartPart1_askUserForTitle() {


        MCAlertWithTextEntry.presentAlertWithTextEntry_alertViewTitle("What would you like to name your new Pie Chart?", forViewController: self) { (userEnteredText) -> Void in

            self.addNewChartPart2_createNewChartAndReload(title:userEnteredText)

        }

    }

    func addNewChartPart2_createNewChartAndReload(title title:NSString){

        // deselect the old charts
        for chart in listOfPieCharts! {

            let nextChart = chart as! PieChartThumbnail
            nextChart.isSelected = false

        }

        // add the new chart and refresh the collectionV
        PieChartThumbnailSubclass.addPieChart(title: title)  // isSelected = true by default

        listOfPieCharts = PieChartThumbnailSubclass.getPieCharts()
        selectedPieChart = PieChartThumbnailSubclass.getTheSelectedPieChart()
        
        collectionView.reloadData()

        // make sure the edit button is enabled
        self.navigationItem.rightBarButtonItem?.enabled = true

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

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("pieCharts", forIndexPath: indexPath) as! ChartCollectionViewCell
        cell.layer.cornerRadius = 10;
        cell.layer.masksToBounds = true;

        updateCell(cell: cell, indexPath:indexPath)
        return cell

    }

    func updateCell(cell cell:ChartCollectionViewCell, indexPath:NSIndexPath){

        // get data object
        let dataObj = listOfPieCharts!.objectAtIndex(indexPath.row) as! PieChartThumbnail

        // get image
        var imageToDisplay:UIImage =  dataObj.snapshot as? UIImage ?? UIImage(named: "defaultPie.png")! as UIImage


        // if selected, change image to black and white
        if dataObj.isSelected == true {

            cell.backgroundColor = color_selected
            cell.alpha = 1.0

        }else{

            cell.backgroundColor = color_unselected
            cell.alpha = alphaForNonSelectedItems
            imageToDisplay = Grayscale.convertToGrayscale_image(imageToDisplay)
            
        }

        cell.titleLabel.attributedText = TextFormatter.createAttributedString(dataObj.chartTitle, withFont: "Papyrus", fontSize: 18, fontColor: UIColor.blackColor(), nsTextAlignmentStyle: NSTextAlignment.Center)
        cell.imageV.image = imageToDisplay

    }

    
    // MARK: COLLECTION VIEW DELEGATE

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        selectCell_singleSelectionOnly(collectionView, didSelectItemAtIndexPath: indexPath)
        collectionView.reloadData()

    }

    func selectCell_singleSelectionOnly(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){

        // select selected item and deselect others, update db

        // deselect all
        // (hmm... is this faster than using a conditional? would the compiler reinterpret it?)
        for chart in listOfPieCharts! {

            let theChart = chart as! PieChartThumbnail
            theChart.isSelected = false

        }

        // select selected item
        let selectedItem = listOfPieCharts?.objectAtIndex(indexPath.row) as! PieChartThumbnail
        selectedItem.isSelected = true
        selectedPieChart = selectedItem

        // save to db
        let err = NSErrorPointer()
        do {
            try PieChartThumbnailSubclass.getMOC().save()
        } catch let error as NSError {
            err.memory = error
        }

        // make sure the edit button is enabled
        self.navigationItem.rightBarButtonItem?.enabled = true
        
    }


    // MARK: SEGUE TO EDIT VIEW

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        let vc = segue.destinationViewController as! EditChartViewController
        vc.pieChartBeingEdited = selectedPieChart
        vc.colors = colors
        vc.showAlertMessageWhenReturnToThisScreen = true

    }

}
