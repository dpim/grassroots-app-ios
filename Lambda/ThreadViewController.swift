//
//  SecondViewController.swift
//  Lambda
//
//  Created by Dmitry Pimenov on 5/13/17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import UIKit
import Alamofire

class ThreadViewController: LambdaBaseTableViewController {
    var threads: [Thread]?
    var detailedViewer: Bool
    var topic: Topic?
    var topicIndex: Int?
    var lastSelectedId: Int?
    let cellReuseIdentifier = "threadCell"
    let bodyCellReuseIdentifier = "bodyCell"

    
    init(detail: Bool, topic: Topic?){
        self.topic = topic
        self.detailedViewer = detail
        super.init(style: .plain)
    }
    
    init(detail: Bool){
        self.detailedViewer = detail
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.detailedViewer = false
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (self.detailedViewer == true){
            self.navigationController?.navigationBar.topItem?.title = "Topics"
            self.navigationItem.title = self.topic?.displayName
        } else {
            self.navigationController?.navigationBar.topItem?.title = "Threads"
            self.navigationItem.title = "Threads"
        }
        if (self.detailedViewer == true){
            getThreadsForTopic(topicId: self.topic!.id)
        } else {
            getHotThreads()
            getTopics(shouldReload: false)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0){
            if (topic?.body != nil){
                return 1
            } else {
                return 0
            }
        } else {
            if let threads = self.threads {
                if (threads.count == 0){
                    return 1
                } else {
                    return threads.count
                }
            } else {
                return 0
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0){
            if let cell = tableView.dequeueReusableCell(withIdentifier: bodyCellReuseIdentifier) as? BodyViewCell{
                self.setLayerForBodyCell(cell: cell)
                cell.bodyTextLabel.text = self.topic?.body
                return cell
            } else {
                let cell = UITableViewCell(style: .default, reuseIdentifier: "placeholder")
                return cell
            }
        } else {
            if (threads == nil || threads?.count == 0){
                if let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as? ThreadViewCell{
                    self.setUpAsPlaceholderCell(cell: cell)
                    return cell
                } else {
                    let cell = ThreadViewCell(style: .default, reuseIdentifier: cellReuseIdentifier)
                    return cell
                }
            } else {
                let currentThread = threads?[indexPath.row]
                if let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as? ThreadViewCell{
                    self.setUpCell(cell: cell, currentThread: currentThread)
                    return cell
                } else {
                    let cell = ThreadViewCell(style: .default, reuseIdentifier: cellReuseIdentifier)
                    self.setUpCell(cell: cell, currentThread: currentThread)
                    return cell
                }
            }
        }
    }
    
    func setUpAsPlaceholderCell(cell: ThreadViewCell){
        cell.titleLabel.text = "Start the discussion!"
        cell.userLabel.text = "Touch here to create a new thread"
        cell.previewLabel.text = "👆"
        cell.countCircleView.alpha = 0.0
        setLayerForPlaceHolderCell(cell: cell)
    }
    
    func setUpCell(cell: ThreadViewCell, currentThread: Thread?){
        cell.countCircleView.alpha = 1.0
        cell.titleLabel.text = currentThread?.title ?? "Thread"
        cell.userLabel.text = currentThread?.displayName ?? "OP"
        cell.dateLabel.text = "Today"
        cell.previewLabel.text = previewText(string: currentThread?.body) ?? "-"
        cell.countLabel.text = "\(currentThread?.countComments ?? 0)"
        setLayerForCell(cell: cell)
        
        if let stringId = UserDefaults.standard.object(forKey: "id") as? String {
            if let id = Int(stringId){
                if (currentThread?.userId == id) {
                    cell.userLabel.text = "\(cell.userLabel.text!) ⭐️"
                }
            }
        }
    }
    
    func setLayerForCell(cell: ThreadViewCell){
        cell.titleLabel.textColor = UIColor.white
        cell.userLabel.textColor = UIColor.white
        cell.dateLabel.textColor = UIColor.white
        cell.previewLabel.textColor = UIColor.white
        cell.countLabel.textColor = UIColor.black
        cell.countCircleView.backgroundColor = UIColor.white
        cell.cellView.layer.cornerRadius = cornerRadius
        cell.cellView.layer.borderWidth = borderWidth
        cell.cellView.layer.borderColor = Theme.Dark.mainColor.cgColor
        cell.cellView.backgroundColor = Theme.Graphical.mainColor
    }
    
    func setLayerForBodyCell(cell: BodyViewCell){
        cell.bodyTextLabel.textColor = UIColor.white
        cell.cellView.layer.cornerRadius = cornerRadius
        cell.cellView.layer.borderWidth = borderWidth
        cell.cellView.layer.borderColor = Theme.Dark.mainColor.cgColor
        cell.cellView.backgroundColor = Theme.Dark.mainColor
    }
    
    func setLayerForPlaceHolderCell(cell: ThreadViewCell){
        cell.titleLabel.textColor = UIColor.white
        cell.userLabel.textColor = UIColor.white
        cell.dateLabel.textColor = UIColor.white
        cell.previewLabel.textColor = UIColor.white
        cell.countLabel.textColor = UIColor.black
        cell.countCircleView.backgroundColor = UIColor.white
        cell.cellView.layer.cornerRadius = cornerRadius
        cell.cellView.layer.borderWidth = borderWidth
        cell.cellView.layer.borderColor = Theme.Dark.mainColor.cgColor
        cell.cellView.backgroundColor = Theme.Default.mainColor
    }
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if (indexPath.section == 1){
            let cell  = tableView.cellForRow(at: indexPath) as! ThreadViewCell
            cell.contentView.backgroundColor = Theme.Graphical.mainColor
            cell.cellView.layer.borderWidth = 0.0
        }
    }
    
    override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if (indexPath.section == 1){
            let cell  = tableView.cellForRow(at: indexPath) as! ThreadViewCell
            cell.contentView.backgroundColor = UIColor.clear
            cell.cellView.layer.borderWidth = borderWidth
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 1){
            if ((self.threads?.count)! > 0){
                self.lastSelectedId = indexPath.row
                if (self.detailedViewer == true){
                    self.performSegue(withIdentifier: "threadsToDetailed", sender: self)
                } else {
                    self.performSegue(withIdentifier: "threadsToThread", sender: self)
                }
            } else {
                self.performSegue(withIdentifier: "threadsToNew", sender: self)
            }
        }
    }
    
    func getHotThreads(){
        if (isValidLocation()){
            let coords = self.appDelegate.locationManager.location?.coordinate
            guard let latitude = coords?.latitude else {
                getGenericThreads()
                return
            }
            guard let longitude = coords?.longitude else {
                getGenericThreads()
                return
            }
            let location = "\(latitude),\(longitude)"
            Alamofire.request("\(apiUrl)/hotthreads/\(location)", method: .get).responseJSON {
                response in switch response.result {
                case .success(let JSON):
                    var threadsArr = [Thread]()
                    let response = JSON as! NSArray
                    for threadResponse in response {
                        if let threadResponseDict = threadResponse as? Dictionary<String, Any> {
                            let thread = Thread(dateCreated: threadResponseDict["datecreated"] as? Date,
                                                id: threadResponseDict["id"] as! Int,
                                                title: threadResponseDict["title"] as? String,
                                                displayName: threadResponseDict["displayname"] as? String,
                                                dateUpdated: threadResponseDict["dateupdated"] as? Date,
                                                parentId: threadResponseDict["parentid"] as? Int,
                                                body: threadResponseDict["body"] as? String,
                                                userId: threadResponseDict["userid"] as? Int,
                                                didUpvote: threadResponseDict["didUpvote"] as? Bool,
                                                countUpvotes: threadResponseDict["countUpvotes"] as? Int,
                                                countComments: threadResponseDict["countComments"] as? Int)
                            threadsArr.append(thread)
                        }
                    }
                    self.threads = threadsArr
                    self.tableView.reloadData()
                case .failure(let error):
                    print("Request failed with error: \(error)")
                }
            }
        }
    }
    
    func getGenericThreads(){
        Alamofire.request("\(apiUrl)/hotthreads", method: .get).responseJSON {
            response in switch response.result {
            case .success(let JSON):
                var threadsArr = [Thread]()
                let response = JSON as! NSArray
                for threadResponse in response {
                    if let threadResponseDict = threadResponse as? Dictionary<String, Any> {
                        let thread = Thread(dateCreated: threadResponseDict["datecreated"] as? Date,
                                            id: threadResponseDict["id"] as! Int,
                                            title: threadResponseDict["title"] as? String,
                                            displayName: threadResponseDict["displayname"] as? String,
                                            dateUpdated: threadResponseDict["dateupdated"] as? Date,
                                            parentId: threadResponseDict["parentid"] as? Int,
                                            body: threadResponseDict["body"] as? String,
                                            userId: threadResponseDict["userid"] as? Int,
                                            didUpvote: threadResponseDict["didUpvote"] as? Bool,
                                            countUpvotes: threadResponseDict["countUpvotes"] as? Int,
                                            countComments: threadResponseDict["countComments"] as? Int)
                        threadsArr.append(thread)
                    }
                }
                self.threads = threadsArr
                self.tableView.reloadData()
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }

    
    func getThreadsForTopic(topicId: Int){
        Alamofire.request("\(apiUrl)/topics/\(topicId)", method: .get).responseJSON {
            response in switch response.result {
            case .success(let JSON):
                var threadsArr = [Thread]()
                let response = JSON as! NSArray
                for threadResponse in response {
                    if let threadResponseDict = threadResponse as? Dictionary<String, Any> {
                        let thread = Thread(dateCreated: threadResponseDict["datecreated"] as? Date,
                                            id: threadResponseDict["id"] as! Int,
                                            title: threadResponseDict["title"] as? String,
                                            displayName: threadResponseDict["displayname"] as? String,
                                            dateUpdated: threadResponseDict["dateupdated"] as? Date,
                                            parentId: threadResponseDict["parentid"] as? Int,
                                            body: threadResponseDict["body"] as? String,
                                            userId: threadResponseDict["userid"] as? Int,
                                            didUpvote: threadResponseDict["didUpvote"] as? Bool,
                                            countUpvotes: threadResponseDict["countUpvotes"] as? Int,
                                            countComments: threadResponseDict["countComments"] as? Int)
                        threadsArr.append(thread)
                    }
                }
                self.threads = threadsArr
                self.tableView.reloadData()
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "threadsToThread" {
            if segue.destination is ThreadDetailViewController {
                if let destination = segue.destination as? ThreadDetailViewController {
                    destination.threadId = threads?[self.lastSelectedId!].id
                    destination.thread = threads?[self.lastSelectedId!]
                }
            }
        } else if segue.identifier == "threadsToDetailed" {
            if segue.destination is ThreadDetailViewController {
                if let destination = segue.destination as? ThreadDetailViewController {
                    destination.threadId = threads?[self.lastSelectedId!].id
                    destination.thread = threads?[self.lastSelectedId!]
                }
            }
        } else if segue.identifier == "threadsToNew" {
            if segue.destination is NewThreadViewController {
                if let destination = segue.destination as? NewThreadViewController {
                    if let topics = self.topics {
                        destination.topics = topics
                    }
                    if let topic = self.topic {
                        destination.currentTopicName = topic.displayName
                        destination.currentTopicIdx = self.topicIndex!
                    }
                }
            }
        }
    }
    
    func previewText(string: String?) -> String? {
        if let bodyString = string {
            if bodyString.characters.count > 100 {
                return bodyString.substring(to: bodyString.index(bodyString.startIndex, offsetBy: 100))
            } else {
                return string
            }
        } else {
            return string
        }
    }
    
    override func refresh() {
        if (self.detailedViewer == true){
            getThreadsForTopic(topicId: self.topic!.id)
        } else {
            getHotThreads()
            getTopics(shouldReload: false)
        }
        self.refreshControl?.endRefreshing()
    }
}

