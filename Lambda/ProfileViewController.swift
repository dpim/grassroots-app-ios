//
//  ProfileViewController.swift
//  Lambda
//
//  Created by Dmitry Pimenov on 5/21/17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import Foundation
import UIKit

class ProfileViewController: UITableViewController {
    
    @IBOutlet var userLabel: UILabel!
    @IBOutlet var helpLabel: UILabel!
    
    let accountSection = 0
    let lambdaSection = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userLabel.text = UserDefaults.standard.string(forKey: "username")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Profile"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == accountSection){
            if (indexPath.row == 1){ //logout out row
                logout()
            }
        } else if (indexPath.section == lambdaSection){
            if (indexPath.row == 0){
                
            }
        } else {
            //do nothing
        }
    }
    
    func logout(){
        clearCookies()
        clearDefaults()
        switchToLoginNavigationController()
    }
    
    func clearCookies(){
        if let cookies = HTTPCookieStorage.shared.cookies(for: baseUrlObj) {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
    }
    
    func switchToLoginNavigationController() -> Void {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let navController: UINavigationController = storyboard.instantiateViewController(withIdentifier: "LoginNavigationViewController") as! UINavigationController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = navController
     
    }
    
    func clearDefaults(){
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "id")
    }
}
