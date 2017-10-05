//
//  ShiftyBaseViewController.swift
//  Lambda
//
//  Created by Dmitry Pimenov on 5/21/17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import Foundation
import UIKit

class ShiftBaseViewController : UIViewController {
    var keyboardShiftMultiplier: CGFloat = 0.0

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (self.view.frame.height < 500){
            self.keyboardShiftMultiplier = 0.3
        }
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height*keyboardShiftMultiplier
            }
        }
    }
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height*keyboardShiftMultiplier
            }
        }
    }
    func saveKey(key: String, value: Any){
        UserDefaults.standard.set(value, forKey: key)
    }
}
