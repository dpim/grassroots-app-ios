//
//  LoginViewController.swift
//  Lambda
//
//  Created by Dmitry Pimenov on 5/13/17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftKeychainWrapper

class LoginViewController: ShiftBaseViewController, UITextFieldDelegate {
    
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var circleView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        if (self.view.frame.height < 500){
            self.circleView.isHidden = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login(sender: UIButton){
        if let username = usernameTextField.text, let password = passwordTextField.text {
            let loginParams: Parameters = [
                "username": username,
                "password": password
            ]
            Alamofire.request("\(baseUrl)/login", method: .post, parameters: loginParams).responseJSON {
                response in switch response.result {
                case .success(let JSON):
                    if let dict = JSON as? Dictionary<String, AnyObject> {
                        self.saveKey(key: "username", value: username)
                        self.saveKey(key: "id", value: "\(dict["userId"]!)")
                        if KeychainWrapper.standard.set(password, forKey: "lambda-password") { //returns bool if saved successfully
                            let headerFields = response.response?.allHeaderFields
                            let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields as! [String : String], for: baseUrlObj)
                            HTTPCookieStorage.shared.setCookies(cookies, for: baseUrlObj, mainDocumentURL: nil)
                            //go to main ui
                            self.switchToPrimaryNavigationController()
                        }
                    }
                case .failure(let error):
                    print(error)
                    let alert = UIAlertController(title: "Unable to sign in", message: "We weren't able to sign you in. Please check your credentials and try again.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = self.view.viewWithTag(textField.tag+1) as? UITextField {
            nextTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            login(sender: UIButton())
        }
        return false
    }
    
    func switchToPrimaryNavigationController() -> Void {
        let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let tabViewController = mainStoryboard.instantiateViewController(withIdentifier: "TabViewController") as! UITabBarController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = tabViewController
    }

}

