//
//  LambdaBaseTableViewController.swift
//  Lambda
//
//  Created by Dmitry Pimenov on 6/10/17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import CoreLocation

class LambdaBaseTableViewController: UITableViewController {
    var overlay : UIView?
    var topics : [Topic]?
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl!.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl!.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        tableView.refreshControl = refreshControl
        //tableView?.insertSubview(refreshControl!, at: 0)
        //tableView?.sendSubview(toBack: refreshControl!)
    }
    
    override func viewDidLayoutSubviews() {
        if let refreshControl = self.refreshControl {
            refreshControl.superview?.sendSubview(toBack: refreshControl)
        }
    }
    
    func getTopics(shouldReload: Bool){
        if (isValidLocation()){
            let coords = self.appDelegate.locationManager.location?.coordinate
            guard let latitude = coords?.latitude else {
                getGenericTopics(shouldReload:shouldReload)
                return
            }
            guard let longitude = coords?.longitude else {
                getGenericTopics(shouldReload:shouldReload)
                return
            }
            let location = "\(latitude),\(longitude)"
            Alamofire.request("\(apiUrl)/hottopics/\(location)", method: .get).responseJSON {
                response in switch response.result {
                case .success(let JSON):
                    var topicsArr = [Topic]()
                    let response = JSON as! NSArray
                    for topicResponse in response {
                        if let topicResponseDict = topicResponse as? Dictionary<String, Any> {
                            let topic = Topic(dateCreated: topicResponseDict["datecreated"] as? Date, id: topicResponseDict["id"] as! Int,
                                              displayName: topicResponseDict["displayname"] as? String,
                                              dateUpdated: topicResponseDict["dateupdated"] as? Date,
                                              parent: topicResponseDict["parent"] as? String,
                                              body: topicResponseDict["body"] as? String)
                            topicsArr.append(topic)
                        }
                    }
                    self.topics = topicsArr.reversed()
                    if (shouldReload){
                        self.tableView.reloadData()
                    }
                case .failure(let error):
                    print("Request failed with error: \(error)")
                }
            }
        } else {
            getGenericTopics(shouldReload:shouldReload)
        }
    }
    
    private func getGenericTopics(shouldReload: Bool){
        Alamofire.request("\(apiUrl)/hottopics/", method: .get).responseJSON {
            response in switch response.result {
            case .success(let JSON):
                var topicsArr = [Topic]()
                let response = JSON as! NSArray
                for topicResponse in response {
                    if let topicResponseDict = topicResponse as? Dictionary<String, Any> {
                        let topic = Topic(dateCreated: topicResponseDict["datecreated"] as? Date, id: topicResponseDict["id"] as! Int,
                                          displayName: topicResponseDict["displayname"] as? String,
                                          dateUpdated: topicResponseDict["dateupdated"] as? Date,
                                          parent: topicResponseDict["parent"] as? String,
                                          body: topicResponseDict["body"] as? String)
                        topicsArr.append(topic)
                    }
                }
                self.topics = topicsArr.reversed()
                if (shouldReload){
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }


    func refresh(){
        //do something
    }
    
}
