//
//  File.swift
//  Lambda
//
//  Created by Dmitry Pimenov on 5/13/17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import Foundation
import UIKit

class SplashViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func moveToRegistration(sender: UIButton){
        self.performSegue(withIdentifier: "splashToRegistration", sender: sender)
    }
    
    @IBAction func moveToSignIn(sender: UIButton){
        self.performSegue(withIdentifier: "splashToLogin", sender: sender)
    }
}

