//
//  File.swift
//  Lambda
//
//  Created by Dmitry Pimenov on 6/18/17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import Foundation
import UIKit

class TopicViewCell: UITableViewCell {
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var cellLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
}
