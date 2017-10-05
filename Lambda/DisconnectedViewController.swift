//
//  DisconnectedViewController.swift
//  Lambda
//
//  Created by Dmitry Pimenov on 5/21/17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import Foundation
import UIKit

class DisconnectedViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(DisconnectedViewController.pollConnection), userInfo: nil, repeats: true)
    }
    
    func pollConnection(){
        if (Reachability.connectedToNetwork()){
            self.view.removeFromSuperview()
        }
    }
}
