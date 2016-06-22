//
//  TimerViewController.swift
//  PieChart
//
//  Created by xcode on 2/17/15.
//  Copyright (c) 2015 MSCline. All rights reserved.
//



// WE CAN TRACK DIFFERENT CATEGORIES USING OUR TIMERS
// CATEGORIES ARE AVAILABLE TO BE USED BY PIE CHARTS

// A CATEGORY HAS A TITLE, TOTAL VALUE, AND COLOR

import UIKit

class TimerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {


        // INSTANCE VARIABLES
        var categories:NSArray?
        var colors:NSArray?
        var colorNames:NSArray?

        var selectedCategory:TrackingCategory?
        var logRecord:LogRecord?

        // CLOCK
        var elapsedTimeForSelectedCategory = 0.0
        var clockLabelToUpdate:UILabel?
        var correctClockLabelTagNumber:Int?    // used to check not updating reused cell item
        var clockTickEveryXSeconds = 0.01

        // EDITING MODE
        var editingModeIsOn = false
        let collectionViewLayoutDefault = CollectionViewLayout()
        var collectionViewLayoutEditing:UICollectionViewLayout?

        var addBarButton:UIBarButtonItem!
        var backBarButton:UIBarButtonItem!

        // OUTLETS
        @IBOutlet weak var collectionV: UICollectionView!
        @IBOutlet weak var stopButton: UIButton!
        @IBOutlet weak var constraints_CVLeft: NSLayoutConstraint!
        @IBOutlet weak var constraint_CVRight: NSLayoutConstraint!

        // CONSTANTS
        let defaultAlpha:CGFloat = 0.65 
        let isHiddenTitle = "Unhide"
        let isNotHiddenTitle = "Hide"


    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // save current collection flow layout and change to circle
        collectionViewLayoutEditing = collectionV.collectionViewLayout
        collectionV.collectionViewLayout = collectionViewLayoutDefault
        reloadData()

        // save bar buttons so can rearrange (don't like this implementation)
        addBarButton = self.navigationItem.leftBarButtonItem
        backBarButton = self.navigationItem.rightBarButtonItem

        // set up timer to notify you every x seconds
        // use to increment category's clock
        NSTimer.scheduledTimerWithTimeInterval(clockTickEveryXSeconds, target: self, selector: "clockTick", userInfo: nil, repeats: true)

    }

    func reloadData(){

        getListOfCategoriesAndCheckToSeeIfTimerRunning()
        collectionV.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: defaultAlpha)  // old UIColor(red: 255/255.0, green: 255/255.0, blue: 102/255.0, alpha: defaultAlpha)
        collectionV.reloadData()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        stopButton.layer.cornerRadius = 5

    }

    func getListOfCategoriesAndCheckToSeeIfTimerRunning(){

        getCategoriesFromDatabase()
        logRecord = nil

        // if the app exits and is reloaded, need to look to see if tracking
        // any categories by looking at the logRecord
        // there can only be one open logRecord at a time, so just
        // look to see if there is one without a checkout date

        let lastRecord = LogRecordSubclass.returnLastLog() as NSArray
        if lastRecord.count > 0 {

            logRecord = lastRecord.objectAtIndex(0) as? LogRecord
            selectedCategory = logRecord!.logRecordsCategory as TrackingCategory

            elapsedTimeForSelectedCategory = NSDate().timeIntervalSinceDate(logRecord!.checkinTime)
            self.navigationItem.rightBarButtonItem?.enabled = true
            stopButton.alpha = 1.0

        } else {

            stopButton.alpha = defaultAlpha
        }

    }


    // MARK: BUTTONS

    @IBAction func onStopButtonPressed(sender: AnyObject) {

        stopTimer()
        collectionV.reloadData()  // need to update display

    }


    @IBAction func onNewCategoryButtonPressed(sender: AnyObject) {

        addCategoryPart1_startByAskingUserForTitle()

    }

    @IBAction func onEditButtonPressed(sender: AnyObject) {

        toggleEditingMode()

    }


    // MARK: BUTTONS ON CELL (HANDLED HERE)

    @IBAction func onDeleteButtonPressed(sender: UIButton) {

        // when created cell, set the button's tag to the row number so we can know the row number we are working with
        let trackingC = categories?.objectAtIndex(sender.tag) as TrackingCategory
        deleteCategory(trackingC)

        // reload any active cells
        reloadData()

    }

    @IBAction func onLogButtonPressed(sender: TimerCollectionViewCell) {


        let dataObject = categories?.objectAtIndex(sender.tag) as TrackingCategory

        performSegueWithIdentifier("toDetail", sender: dataObject)

    }

    @IBAction func onDidEndOnExit(sender: UITextField) {

        // when created cell, set the button's tag to the row number so we can know the row number we are working with
        let trackingC = categories?.objectAtIndex(sender.tag) as TrackingCategory

        sender.resignFirstResponder()
        saveTitleIfEdited(trackingCat: trackingC, textField: sender)

    }

    @IBAction func onHideButtonTapped(sender: AnyObject) {

        // when created cell, set the button's tag to the row number so we can know the row number we are working with
        let trackingC = categories?.objectAtIndex(sender.tag) as TrackingCategory

        // the buttons would flash upon reuse, so put a label under the button to display text (grr)
        // so need to get the label so can change
        let indexPath = NSIndexPath(forRow: sender.tag, inSection: 0)
        let cell = collectionV.cellForItemAtIndexPath(indexPath) as TimerCollectionViewCell

        // get the cell from the collection view and then use it
        toggleCategoryIsHidden(timer: trackingC, labelToUpdate: cell.hideLabel)
        
    }

    @IBAction func onChangeColorButtonPressed(sender: AnyObject) {

        // when created cell, set the button's tag to the row number so we can know the row number we are working with
        let trackingC = categories?.objectAtIndex(sender.tag) as TrackingCategory

        // reuse old code - get color using alert view
        addCategoryPart2_thenAskForColor { (color) -> () in

            // save color
            trackingC.color = color

            var err = NSErrorPointer()
            TrackingCategorySubclass.getMOC().save(err)

            // reload cell
            self.reloadData()

        }

    }

    // MARK: START & STOP TIMERS

    func startTimer(forCategory:TrackingCategory){

        selectedCategory = forCategory
        self.navigationItem.rightBarButtonItem?.enabled = true

        // create new logRecord for category
        // (here, we are really just keeping start and stop time)
        let date = NSDate()
        logRecord = LogRecordSubclass.addNewLogRecord(checkinTime: date, parentCategory: forCategory)

        // start clock / counter
        // (the clock is just a scrolling counter)
        elapsedTimeForSelectedCategory = 0

        // remove alpha on stop button
        stopButton.alpha = 1.0

    }

    func stopTimer(){

        if logRecord != nil {

            LogRecordSubclass.updateLastLogUponCheckout(record: logRecord!)

        }

        // clear old values
        selectedCategory = nil
        logRecord = nil

        // add alpha to stop button
        stopButton.alpha = defaultAlpha

    }

    func clockTick(){

        elapsedTimeForSelectedCategory = elapsedTimeForSelectedCategory + clockTickEveryXSeconds

        if clockLabelToUpdate == nil { return; }

        // check to make sure the cell you are updating corresponds to the correct category (ie, they have the same index path)
        if clockLabelToUpdate?.tag == correctClockLabelTagNumber {

                clockLabelToUpdate?.attributedText = formatText(formatTime(elapsedTimeForSelectedCategory))

        }
        
    }

    func formatTime(elapsedTime:Double)->(String){


        // CALC HOURS, MIN, SEC, HUNDRETHS (just did it by hand, alternatively could have used function)

        // number of hours = time in sec (1 hour / 60 min)(1 min / 60 sec) with no remainder
        let hours = Int(elapsedTimeForSelectedCategory / 3600)

        // min
        // 1) the number of min is what is left over after we have taken the hours out - use mod 3600
        // 2) number of min = time in sec (1 min / 60 sec) with no remainder
        let min = Int((elapsedTimeForSelectedCategory % 3600)/60)

        // sec - whatever is left, after you remove the hours and min
        let sec = Int(elapsedTimeForSelectedCategory % 60)

        // hundreths - get two dec places, I just multiplied by 100 and used Int to get rid of dec
        // let hundreths = Int(elapsedTimeForSelectedCategory*100)-Int(elapsedTimeForSelectedCategory)*100


        // PUT IN LEADING ZEROES
        var seconds = ""

        if sec == 0 {

            seconds = String(stringLiteral: "00")

        }else if sec < 10 {

            seconds = String(stringLiteral: "0\(sec)")

        }else{

            seconds = String(stringLiteral: "\(sec)")
        }


        // BUILD STRING
        return String(stringLiteral: "\(hours):\(min):\(seconds)")

    }


    // MARK: EDITING MODE

    func toggleEditingMode(){


        editingModeIsOn = !editingModeIsOn

        if editingModeIsOn == true {

            switchToEditingModeAndReload()

        } else {

            turnEditingModeOff()

        }

    }

    func switchToEditingModeAndReload(){

        // move right button ("Edit" or "Done") to left bar spot
        self.navigationItem.rightBarButtonItem?.title = "Done"
        self.navigationItem.leftBarButtonItem? = backBarButton

        // get rid of right button
        self.navigationItem.rightBarButtonItem? = UIBarButtonItem()
        self.navigationItem.rightBarButtonItem?.enabled = false

        self.navigationItem.title = "Edit Timers"

        animateToStandardLayout()
      //  collectionV.collectionViewLayout = collectionViewLayoutEditing!

        // set tint color
        let window = UIApplication.sharedApplication().delegate?.window!
        window?.tintColor = UIColor.orangeColor()

        getCategoriesFromDatabase()
        collectionV.reloadData()

    }

    func turnEditingModeOff(){

        editingModeIsOn = false // if not already done


        // move backBarButton back to right side
        self.navigationItem.rightBarButtonItem? = backBarButton
        self.navigationItem.rightBarButtonItem?.title = "Edit"
        self.navigationItem.rightBarButtonItem?.enabled = true

        self.navigationItem.leftBarButtonItem? = addBarButton

        self.navigationItem.title = "Timers"

        // if in portrait, use circle collection view layout
        if self.view.frame.size.height > self.view.frame.size.width {

            self.animateToCircle()


        // if not, use standard layout
        }else{

            self.animateToStandardLayout()
        }

        // set tint color
        let window = UIApplication.sharedApplication().delegate?.window!
        window?.tintColor = UIColor.blueColor()

        reloadData()
        
    }


    // MARK: CRUD

    func getCategoriesFromDatabase(){

        if editingModeIsOn == true {

            categories = TrackingCategorySubclass.returnListOfCategories()

        }else{

            categories = TrackingCategorySubclass.returnListOfTimersMarkedUnhidden()

        }

    }
    func deleteCategory(category:TrackingCategory){

        TrackingCategorySubclass.delTrackingCategory(obj: category)

        getCategoriesFromDatabase()
        collectionV.reloadData()

    }

    func addCategoryPart1_startByAskingUserForTitle(){

        MCAlertWithTextEntry.presentAlertWithTextEntry_alertViewTitle("Add new category", forViewController: self) { (userEnteredText) -> Void in

            // on completion run
            self.addCategoryPart2_thenAskForColor(completionBlock: { (color) -> () in

                self.addCategoryPart3_createNewCategory(title: userEnteredText, color: color)

            })

        }
    }

    func addCategoryPart2_thenAskForColor(#completionBlock:(UIColor)->()){

        let alert = UIAlertController(title: "Select Color", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)

        var counter = 0

        // add a line in action sheet for each color
        for color in colors! {

            let colorToAdd = color as UIColor
            let action = UIAlertAction(title: colorNames?.objectAtIndex(counter) as NSString, style: UIAlertActionStyle.Default, handler: { (uiAlertAction) -> Void in

                completionBlock(colorToAdd)  // this color is preloaded when create action

            })

            alert.addAction(action)
            counter++
        }

        presentViewController(alert, animated: true) { () -> Void in }

    }

    func addCategoryPart3_createNewCategory(#title:NSString, color:UIColor){

        let ourTitle = title ?? ""
        TrackingCategorySubclass.addNewTrackingCategory(title:ourTitle, totalValue: 0, color: color)
        getListOfCategoriesAndCheckToSeeIfTimerRunning()
        collectionV.reloadData()
        
    }

    func saveTitleIfEdited(#trackingCat:TrackingCategory, textField:UITextField){


        // save title
        var err = NSErrorPointer()
        trackingCat.title = textField.text

        let didSave = TrackingCategorySubclass.getMOC().save(err)
        if didSave == false || err != nil {

            println("error: \(err)")

        }

    }

    func toggleCategoryIsHidden(#timer:TrackingCategory, labelToUpdate:UILabel){

        // toggle isHidden property
        // update screen without reloading (or get annoying error as apple changes reuse cells and initiates a button press look as the first cell changes title)
        if timer.timerIsHidden == 1 {

            timer.timerIsHidden = 0
            labelToUpdate.text = isNotHiddenTitle
            
        }else{

            timer.timerIsHidden = 1
            labelToUpdate.text = isHiddenTitle

        }


        // save
        var err = NSErrorPointer()
        TrackingCategorySubclass.getMOC().save(err)

    }


    // MARK: COLLECTION VIEW DATA SOURCE

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {

        return 1

    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if categories == nil {return 0;}

        return categories!.count

    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {


        // get cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("aaa", forIndexPath: indexPath) as TimerCollectionViewCell
        cell.layer.masksToBounds = true;

        // update content
        updateCell(cell: cell, indexPath:indexPath)
        ifSelectedCategoryFormatAndSetupClockCounter(cell: cell, indexPath: indexPath)
        turnFeaturesOnOrOffIfInEditingModeOrNot(cell: cell, indexPath: indexPath)


        return cell
        
    }

    func updateCell(#cell:TimerCollectionViewCell, indexPath:NSIndexPath){

        // get corresponding data object
        let dataObject = categories?.objectAtIndex(indexPath.row) as TrackingCategory

        let defaultText_elapsedTime = "0:0:00"

        // format text
        var formattedTitle = formatTextForTimers(text: dataObject.title, fontSize: 14)

       // formattedTitle = resizeTextIfNeeded(labelWidth: cell.textLabel.frame.size.width, fontSize: 14.0, attributedText: formattedTitle)
        
        // set
        cell.storageView.backgroundColor = dataObject.color as? UIColor
        cell.storageView.alpha = defaultAlpha
        
        cell.textLabel.attributedText = formattedTitle
        cell.textLabel.backgroundColor = UIColor.clearColor()
        cell.layoutIfNeeded()

        cell.elapsedTime.attributedText = formatText(defaultText_elapsedTime)

        // add highlight when tapped
        cell.viewLogLabel.showsTouchWhenHighlighted = true
        cell.changeColorButton.showsTouchWhenHighlighted = true

        // set tags subviews (now when hit, we know which tag we are working with)
        cell.hideLabel.tag = indexPath.row
        cell.hideLabelButtonOverTop.tag = indexPath.row
        cell.changeColorButton.tag = indexPath.row
        cell.textLabel.tag = indexPath.row
        cell.viewLogLabel.tag = indexPath.row
        cell.deleteButton.tag = indexPath.row  // save row so can look up cell later



        cell.elapsedTime.tag = -1  // ie, invalidate the tag, so if reused won't be associated with any objects

        if dataObject.timerIsHidden == 0 {

            cell.hideLabel.text = isNotHiddenTitle

        }else{

            cell.hideLabel.text = isHiddenTitle

        }

        //TextFormatter.printListOfFontFamilyNames()

    }

    func formatText(text:String)->(NSAttributedString){

        return TextFormatter.createAttributedString(text, withFont: "Damascus", fontSize: 28.0, fontColor: UIColor.greenColor(), nsTextAlignmentStyle: NSTextAlignment.Center) as NSAttributedString

    }

    func formatTextForTimers(#text:String, fontSize:CGFloat)->(NSAttributedString){

        let uppercaseText = text.uppercaseString

        return TextFormatter.createAttributedString(uppercaseText, withFont: "Futura", fontSize: fontSize, fontColor: UIColor.greenColor(), nsTextAlignmentStyle: NSTextAlignment.Center) as NSAttributedString

    }

    func resizeTextIfNeeded(#labelWidth:CGFloat, fontSize:CGFloat, attributedText:NSAttributedString)->(NSAttributedString){


        // return original text unchanged
        return attributedText


// UPGRADE FOR IPAD (OR TEXT RESIZE OPTION)
// NOT WORKING - MAYBE SUBVIEWS BEING REDRAWN????!!!!
/*
        // try maybe???
        self.collectionV.invalidateIntrinsicContentSize()

        // would need nice to just use
        // cell.textLabel.adjustsFontSizeToFitWidth = true
        // but can't get it to work

        // if doesn't fit, then reduce font size
        let textWidth = attributedText.boundingRectWithSize(CGSizeMake(10000, fontSize+3), options:NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil).size.width

        if textWidth > labelWidth {

            let updatedFontSizeInitial = fontSize * labelWidth / textWidth
            var updatedFontSize = Int(updatedFontSizeInitial)

            if updatedFontSize < 7 {

                updatedFontSize = 8

            } else {

            }

            return formatTextForTimers(text: attributedText.string, fontSize: CGFloat(updatedFontSize))

        }else{

            // return original text unchanged
            return attributedText
        }
*/
    }

    func ifSelectedCategoryFormatAndSetupClockCounter(#cell:TimerCollectionViewCell, indexPath:NSIndexPath){

        // get corresponding data object
        let dataObject = categories?.objectAtIndex(indexPath.row) as TrackingCategory

        // if not select, exit
        if dataObject != selectedCategory {

            return;

        }

        // set default settings
        cell.storageView.alpha = 1.0
        collectionV.bringSubviewToFront(cell)
        
        // setup clock
        // - we will keep track of which view we are updating
        // - then we can tell it to update
        // - just need to check to see that the cell isn't being reused for a different row number
        clockLabelToUpdate = cell.elapsedTime  // our label / bad name

        correctClockLabelTagNumber = indexPath.row
        cell.elapsedTime.tag = indexPath.row

    }

    func turnFeaturesOnOrOffIfInEditingModeOrNot(#cell:TimerCollectionViewCell, indexPath:NSIndexPath){

        if editingModeIsOn == true {
            
            cell.layer.cornerRadius = 10;
            cell.textLabel.userInteractionEnabled = true
            cell.textLabel.textColor = UIColor.whiteColor()

            cell.hideLabel.hidden = false
            cell.viewLogLabel.hidden = false
            cell.deleteButton.hidden = false
            cell.changeColorButton.hidden = false

        } else {

            cell.layer.cornerRadius = cell.frame.width/2;
            cell.textLabel.userInteractionEnabled = false
            cell.textLabel.textColor = UIColor.greenColor()

            cell.hideLabel.hidden = true
            cell.viewLogLabel.hidden = true
            cell.deleteButton.hidden = true
            cell.changeColorButton.hidden = true

        }

    }


    // MARK: COLLECTION VIEW DELEGATE

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        let dataObject = categories?.objectAtIndex(indexPath.row) as TrackingCategory

        if editingModeIsOn == true {

            // do nothing

        } else {

            // if selected new category, stop old timer, start new timer
            if selectedCategory != dataObject {

                stopTimer()
                startTimer(dataObject)
                collectionV.reloadData()

            }

        }

    }


    // MARK: PREPARE SEGUE
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        let timerBeingEdited = sender as TrackingCategory

        var vc = segue.destinationViewController as LogViewController
        vc.selectedTimer = timerBeingEdited

    }

    // MARK: ROTATIONS
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {

        // there is no viewDidTransition, but we can pack something in a completion block
        coordinator.animateAlongsideTransition(nil, completion: { (coordinator) -> Void in

            // only change layout if in editing mode
            if self.editingModeIsOn == true { return;}

            // if moved to portrait, use circle collection view layout
            if self.view.frame.size.height > self.view.frame.size.width {

                self.animateToCircle()

            // if not, use standard layout
            }else{

                // UPGRADE:
                //self.slideIntoStandardLayout_forNonEditingMode() // would be cool, but need to use absolute width and height, I presume (Apple will not allow you to change leading and trailing space on consecutive lines, without screwing it up... something that would take 60 seconds in absolute coordinates take 2 hours using constraints, go apple)
                self.animateToStandardLayout()
            }

          //  self.collectionV.collectionViewLayout.invalidateLayout()
          //  self.collectionV.reloadData()

        })
        
    }


    // MARK: Animations

    func slideIntoStandardLayout_forNonEditingMode(){


        // NOT USED, THE CONSTRAINTS ARE PROBLEMATIC
        // TRY SWITCHING INTO ABSOLUTE COORD (APPLE IS SCREWING IT UP, SAYING THAT THERE IS A CONFLICT AND DOING WHATEVER IT FEELS LIKE INSTEAD)
        self.constraint_CVRight.constant = self.view.frame.width //* 2
        self.constraints_CVLeft.constant = 0.5 * self.view.frame.width

        UIView.animateWithDuration(1, animations: { () -> Void in

            self.collectionV.collectionViewLayout = self.collectionViewLayoutEditing!
            self.collectionV.reloadData()

            }, completion: { (Bool completed) -> Void in

                UIView.animateWithDuration(1, animations: { () -> Void in

                        self.constraints_CVLeft.constant = 0
                        self.constraint_CVRight.constant = self.view.frame.width

                    }, completion: { (Bool completed) -> Void in })
                
        })
    }


    func animateToCircle(){

        UIView.animateWithDuration(1, animations: { () -> Void in

            // wait

            }, completion: { (Bool completed) -> Void in

                UIView.animateWithDuration(1, animations: { () -> Void in

                    self.collectionV.collectionViewLayout = self.collectionViewLayoutDefault

                    }, completion: { (Bool completed) -> Void in

                        self.reloadData()
                })
                
        })
    }

    func animateToStandardLayout(){

        UIView.animateWithDuration(1, animations: { () -> Void in

            // wait


            }, completion: { (Bool completed) -> Void in

                UIView.animateWithDuration(1, animations: { () -> Void in

                    self.collectionV.collectionViewLayout = self.collectionViewLayoutEditing!  // just a standard layout

                    if(self.editingModeIsOn == false){

                        self.collectionV.reloadData()

                    }

                }, completion: { (Bool completed) -> Void in })

        })
    }
}
