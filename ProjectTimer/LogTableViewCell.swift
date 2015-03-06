//
//  LogTableViewCell.swift
//  ProjectTimer
//
//  Created by xcode on 3/6/15.
//  Copyright (c) 2015 MSCline. All rights reserved.
//

import UIKit

class LogTableViewCell: UITableViewCell {



        @IBOutlet weak var button_startTime: UIButton!

        @IBOutlet weak var button_endTime: UIButton!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
