//
//  ThreadViewCell.swift
//  Lambda
//
//  Created by Dmitry Pimenov on 6/18/17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import Foundation
import UIKit

class ThreadViewCell: UITableViewCell {
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var countCircleView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var previewLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.cellView = UIView()
    }
}
