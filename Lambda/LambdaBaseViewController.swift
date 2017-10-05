//
//  LambdaBaseViewController.swift
//  Lambda
//
//  Created by Dmitry Pimenov on 5/21/17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import Foundation
import UIKit

class LambdaBaseViewController: UIViewController {
    var overlay : UIView?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !(Reachability.connectedToNetwork()){
            //not connected
            if overlay == nil {
                let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let disconnectedViewController = mainStoryboard.instantiateViewController(withIdentifier: "DisconnectedViewController") as! DisconnectedViewController
                self.overlay = disconnectedViewController.view
                self.view.addSubview(self.overlay!)
            }
        } else {
            overlay = nil
        }
    }

}
