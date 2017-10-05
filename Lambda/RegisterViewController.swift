//
//  RegisterViewController.swift
//  Lambda
//
//  Created by Dmitry Pimenov on 5/13/17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftKeychainWrapper

class RegisterViewController: ShiftBaseViewController, UITextFieldDelegate {
    
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var circleView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        print(self.view.frame.height)
        if (self.view.frame.height < 500){
            self.circleView.isHidden = true
            self.statusLabel.isHidden = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func register(sender: UIButton){
        if let email = emailTextField.text, let username = usernameTextField.text, let password = passwordTextField.text {
            let emailCheckResult = validEmail(email: email)
            let usernameCheckResult = validName(username: username, email: email)
            let passwordCheckResult = validPassword(password: password)
            //do some checks
            if (emailCheckResult.errorOccurred == false && usernameCheckResult.errorOccurred == false && passwordCheckResult.errorOccurred == false ){
                //make request
                let registrationParams: Parameters = [
                    "username": username,
                    "email": email,
                    "password": password
                ]
                
                let loginParams: Parameters = [
                    "username": username,
                    "password": password
                ]
                
                // All three of these calls are equivalent
                Alamofire.request("\(baseUrl)/create", method: .post, parameters: registrationParams).responseJSON { response in
                    if let responseObj = response.result.value as? NSDictionary {
                        if let warningCount = responseObj["warningCount"] as? Int {
                            if (warningCount > 0){
                                let alert = UIAlertController(title: "Something went wrong", message: "This account already exists. Please use a different username/email combination.", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            } else {
                                //write token
                                //login
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
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                var errorStr = "\n"
                if let emailErrorMessage = emailCheckResult.errorMessage {
                    errorStr += emailErrorMessage + "\n"
                }
                if let usernameErrorMessage = usernameCheckResult.errorMessage {
                    errorStr += usernameErrorMessage + "\n"

                }
                if let passwordErrorMessage = passwordCheckResult.errorMessage {
                    errorStr += passwordErrorMessage + "\n"
                }
                let alert = UIAlertController(title: "Something went wrong", message: errorStr, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = self.view.viewWithTag(textField.tag+1) as? UITextField {
            nextTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            register(sender: UIButton())
        }
        return false
    }
    
    func switchToPrimaryNavigationController() -> Void {
        let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let tabViewController = mainStoryboard.instantiateViewController(withIdentifier: "TabViewController") as! UITabBarController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = tabViewController
    }
    
    func validEmail(email: String) -> RegistrationResult {
        let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        if (email.characters.count < 3){
            return RegistrationResult(errorOccurred: true, errorMessage:"Not a valid email")
        } else {
            if regexMatches(test:email, pattern:emailPattern){
                return RegistrationResult(errorOccurred: false)
            } else {
                return RegistrationResult(errorOccurred: true, errorMessage:"Not a valid email")
            }
        }
    }
    
    func validName(username: String, email: String) -> RegistrationResult {
        //check if long enough
        if (username.characters.count < 4){
            return RegistrationResult(errorOccurred: true, errorMessage:"Please choose a longer username")
        } else {
            return RegistrationResult(errorOccurred: false)
        }
    }
    
    func validPassword(password: String) -> RegistrationResult {
        if (password.characters.count < 6){
            return RegistrationResult(errorOccurred: true, errorMessage:"Please choose a longer password")
        } else {
            return RegistrationResult(errorOccurred: false)
        }
    }
    
    
    func regexMatches(test: String, pattern: String) -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: test)
    }
}

struct RegistrationResult {
    var errorOccurred: Bool
    var errorMessage: String?
    
    init(errorOccurred: Bool) {
        self.errorOccurred = errorOccurred
    }
    
    init(errorOccurred: Bool, errorMessage: String) {
        self.errorOccurred = errorOccurred
        self.errorMessage = errorMessage

    }
}

