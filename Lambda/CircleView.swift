//
//  CircleLabel.swift
//  Lambda
//
//  Created by Dmitry Pimenov on 6/18/17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import Foundation
import UIKit

class CircleView: UIView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = self.frame.height/2
    }
}
