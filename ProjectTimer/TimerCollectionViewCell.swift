//
//  TimerCollectionViewCell.swift
//  ProjectTimer
//
//  Created by xcode on 2/17/15.
//  Copyright (c) 2015 MSCline. All rights reserved.
//

import UIKit

class TimerCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var storageView: UIView!
    @IBOutlet weak var textLabel: UITextField!
    @IBOutlet weak var elapsedTime: UILabel!

    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var hideLabel: UILabel!
    @IBOutlet weak var hideLabelButtonOverTop: UIButton!  // xcode is being weird about my tap gesture recognizer, so just throwing button on top of label to catch touches

    @IBOutlet weak var viewLogLabel: UIButton!  // not using as a button, handled by collection view's did select item (left for button formatting...)
    @IBOutlet weak var changeColorButton: UIButton!

}
