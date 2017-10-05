//
//  Config.swift
//  Lambda
//
//  Created by Dmitry Pimenov on 5/21/17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import Foundation
import UIKit

let baseUrl = "https://lambdaservice.azurewebsites.net/"
let baseUrlObj = URL(string: baseUrl)!
let apiUrl = "https://lambdaservice.azurewebsites.net/v1"

enum Theme {
    case Default, Dark, Graphical
    
    var mainColor: UIColor {
        switch self {
        case .Default:
            return UIColor(red:0.15, green:0.43, blue:0.37, alpha:1.0)
        case .Dark:
            return UIColor(red:0.00, green:0.22, blue:0.17, alpha:1.0)
        case .Graphical:
            return UIColor(red:0.05, green:0.32, blue:0.26, alpha:1.0)            
        }
    }
}

let borderWidth: CGFloat = 1.0
let cornerRadius: CGFloat = 5.0
let sharedApplication = UIApplication.shared
