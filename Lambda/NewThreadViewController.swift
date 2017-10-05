//
//  NewThreadViewController.swift
//  Lambda
//
//  Created by Dmitry Pimenov on 6/18/17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import Foundation
import UIKit
import PlaceholderTextView
import Alamofire

class NewThreadViewController: UIViewController, DropDownMenuDelegate, UITextFieldDelegate, UITextViewDelegate {
    @IBOutlet var dropDownMenu: DropDownMenu!
    @IBOutlet var textField: UITextField!
    @IBOutlet var textView: PlaceholderTextView!
    @IBOutlet var submitButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint! //bottom of view

    var currentTopicName: String?
    var currentTopicIdx: Int?
    var topics: [Topic]? 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.currentTopicName != nil){
            self.navigationController?.navigationBar.topItem?.title = "Topic"
        } else {
            self.navigationController?.navigationBar.topItem?.title = "Threads"
        }
        self.submitButton.isEnabled = false
        self.dropDownMenu.backgroundColor = Theme.Graphical.mainColor
        self.textField.font = UIFont(name: "HelveticaNeue-Medium", size: 17)
        self.textView.font = UIFont(name: "HelveticaNeue-Medium", size: 17)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textView.becomeFirstResponder()
        self.textField.resignFirstResponder()
        return false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.title = "New thread"
        self.dropDownMenu.delegate = self
        self.dropDownMenu.data = topics ?? [Topic(dateCreated: nil, id: 4, displayName: "General discussion", dateUpdated: nil, parent: nil, body: nil)]
        self.dropDownMenu.preferredIndex = self.currentTopicIdx ?? 0
        self.dropDownMenu.parentView = self.view
        self.dropDownMenu.setUp()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    func keyboardWillChangeFrame(_ notification: Notification) {
        let endFrame = ((notification as NSNotification).userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        self.bottomConstraint.constant = view.frame.height - endFrame.origin.y
    }
    
    func listTapped(sender: UIButton){
        print(sender)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        validate()
        return textField.text!.characters.count + (string.characters.count - range.length) <= 50
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        validate()
        return textView.text.characters.count + (text.characters.count - range.length) <= 500
    }
    
    func validate(){
        let title = self.textField.text
        if (title!.characters.count > 4){
            self.submitButton.isEnabled = true
        } else {
            self.submitButton.isEnabled = false
        }
    }
    
    @IBAction func submit(sender: UIButton){
        let topic = self.dropDownMenu.lastSelectedId
        let title = self.textField.text ?? "-"
        let text = self.textView.text ?? "-"
        let parameters: [String: Any] =
            ["text": text,
            "title": title]
        
        Alamofire.request("\(apiUrl)/topics/\(topic)", method: .post,  parameters: parameters, encoding: JSONEncoding.default).responseJSON {
            response in switch response.result {
            case .success(let JSON):
                if let _ = JSON as? Dictionary<String, AnyObject> {
                    self.navigationController?.popViewController(animated: true)
                }
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }

    }
    

}
