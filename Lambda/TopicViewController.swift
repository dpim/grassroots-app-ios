//
//  FirstViewController.swift
//  Lambda
//
//  Created by Dmitry Pimenov on 5/13/17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import UIKit
import MediaPlayer
import Alamofire
import CoreLocation

class TopicViewController: LambdaBaseTableViewController {
    var lastSelectedId: Int?
    var lastSelectedRowIndex: Int?
    var lastRefreshTime: Date?
    let cellReuseIdentifier = "topicCell"
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        self.appDelegate.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        self.appDelegate.locationManager.delegate = self.appDelegate
        self.appDelegate.locationManager.requestWhenInUseAuthorization()
        self.appDelegate.locationManager.startUpdatingLocation()
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveLocationConfirmation), name: NSNotification.Name(rawValue: "locationConfirmation"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Topics"
        getTopics(shouldReload:true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.topics?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let topic = topics?[indexPath.row] {
            self.lastSelectedId = topic.id
            self.lastSelectedRowIndex = indexPath.row
        }
        performSegue(withIdentifier: "topicToThread", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentTopic = topics?[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as? TopicViewCell{
            setUpCell(cell: cell, currentTopic: currentTopic)
            return cell
        } else {
            let cell = TopicViewCell(style: .default, reuseIdentifier: cellReuseIdentifier)
            setUpCell(cell: cell, currentTopic: currentTopic)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell  = tableView.cellForRow(at: indexPath) as! TopicViewCell
        cell.contentView.backgroundColor = Theme.Dark.mainColor
        cell.cellView.layer.borderWidth = 0.0
    }
    
    override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell  = tableView.cellForRow(at: indexPath) as! TopicViewCell
        cell.contentView.backgroundColor = UIColor.clear
        cell.cellView.layer.borderWidth = borderWidth
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "topicToThread" {
            if segue.destination is ThreadViewController {
                if let destination = segue.destination as? ThreadViewController {
                    destination.detailedViewer = true
                    destination.topic = self.topics?[self.lastSelectedRowIndex!]
                    destination.topics = self.topics
                    destination.topicIndex = self.lastSelectedRowIndex
                }
            }
        }
    }
    
    override func refresh() {
        getTopics(shouldReload: true)
        self.refreshControl?.endRefreshing()
    }
    
    
    func setUpCell(cell: TopicViewCell, currentTopic: Topic?){
        cell.cellLabel?.text = currentTopic?.displayName
        setLayerForCell(cell: cell)
    }
    
    func setLayerForCell(cell: TopicViewCell){
        cell.cellLabel?.textColor = UIColor.white
        cell.cellView.layer.cornerRadius = cornerRadius
        cell.cellView.layer.borderWidth = borderWidth
        cell.cellView.layer.borderColor = Theme.Dark.mainColor.cgColor
        cell.cellView.backgroundColor = Theme.Dark.mainColor
    }
    
    func didReceiveLocationConfirmation(){
        //run once
        if (self.lastRefreshTime == nil){
            self.refresh()
            self.lastRefreshTime = Date()
        }
    }
}

