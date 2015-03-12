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
    @IBOutlet weak var viewLogLabel: UIButton!  // not using as a button, handled by collection view's did select item (left for button formatting...)

}
