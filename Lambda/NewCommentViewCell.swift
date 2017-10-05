//
//  NewCommentViewCell.swift
//  Lambda
//
//  Created by Dmitry Pimenov on 6/24/17.
//  Copyright © 2017 Dmitry. All rights reserved.
//


import Foundation
import UIKit

class NewCommentViewCell: UITableViewCell {
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var growingTextView: GrowingTextView!
    @IBOutlet weak var submitButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
}
