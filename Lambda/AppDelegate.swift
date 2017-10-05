//
//  AppDelegate.swift
//  Lambda
//
//  Created by Dmitry Pimenov on 5/13/17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation
import SwiftKeychainWrapper

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    var window: UIWindow?
    var locationManager: CLLocationManager = CLLocationManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        sharedApplication.delegate?.window??.tintColor = Theme.Default.mainColor

        if let username = UserDefaults.standard.object(forKey: "username"), let password = KeychainWrapper.standard.string(forKey: "lambda-password"){
            //get a new cookie
            let loginParams: Parameters = [
                "username": username,
                "password": password
            ]
            Alamofire.request("\(baseUrl)/login", method: .post, parameters: loginParams).responseJSON {
                response in switch response.result {
                case .success(let JSON):
                    if JSON is Dictionary<String, AnyObject> {
                        let headerFields = response.response?.allHeaderFields
                        let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields as! [String : String], for: baseUrlObj)
                        HTTPCookieStorage.shared.setCookies(cookies, for: baseUrlObj, mainDocumentURL: nil)
                        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                        let tabBarController: UITabBarController = storyboard.instantiateViewController(withIdentifier: "TabViewController") as! UITabBarController
                        self.window?.makeKeyAndVisible()
                        self.window?.rootViewController = tabBarController
                        }
                case .failure(let error):
                    print(error)
                }
            }
        } else {
            //show sign in flow
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let navController: UINavigationController = storyboard.instantiateViewController(withIdentifier: "LoginNavigationViewController") as! UINavigationController
            //splashViewController.token = validToken
            self.window?.makeKeyAndVisible()
            self.window?.rootViewController = navController
        }
        return true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "locationConfirmation"), object: nil)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        self.locationManager.stopUpdatingLocation()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        self.locationManager.startUpdatingLocation()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}


