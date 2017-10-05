//
//  ThreadDetailViewController.swift
//  Lambda
//
//  Created by Dmitry Pimenov on 6/11/17.
//  Copyright © 2017 Dmitry. All rights reserved.
//
import UIKit
import MediaPlayer
import Alamofire

class ThreadDetailViewController: LambdaBaseViewController, GrowingTextViewDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableContainerView: UIView!
    
    @IBOutlet weak var inputToolbar: UIToolbar!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint! //bottom of toolbar
    @IBOutlet weak var tableBottomConstraint: NSLayoutConstraint! //bottom of toolbar

    
    var refreshControl: UIRefreshControl?
    var referencing: Comment?
    var textView: GrowingTextView?
    var thread: Thread?
    var threadId: Int?
    var comments: [Comment]?
    var indexToCommentCount: [Int: Int] = [0 : 0]
    var idToIndexMapping: [Int: Int] = [0 : 0]
    var lastSelectedId: Int?
    let cellReuseIdentifier = "commentCell"
    let bodyCellReuseIdentifier = "bodyCell"
    let newCellReuseIdentifier = "newCommentCell"

    let minHeight: CGFloat = 33.3
    let shift = 10
    let maxShift = 50
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setUpTextView()
        setUpRefreshView()
        
        self.navigationController?.navigationBar.topItem?.title = "Threads"
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        self.tableView.contentInset.bottom = 44
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Viewing thread"
        self.navigationController?.toolbar.isHidden = false
        fetchComments()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        if let refreshControl = self.refreshControl {
            refreshControl.superview?.sendSubview(toBack: refreshControl)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0){
            return 1
        } else if (section == 1){
            return self.comments?.count ?? 0
        } else if (section == 2){
            return 0
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 1){
            if let topic = comments?[indexPath.row] {
                self.lastSelectedId = topic.id
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0){
            if let cell = tableView.dequeueReusableCell(withIdentifier: bodyCellReuseIdentifier) as? BodyViewCell{
                cell.bodyTextLabel.text = self.thread?.body ?? "-"
                cell.authorTextLabel.text = self.thread?.displayName ?? "user"
                self.setUpBodyCell(cell: cell)
                return cell
            } else {
                let cell = UITableViewCell(style: .default, reuseIdentifier: "placeholder")
                return cell
            }
        } else if (indexPath.section == 1){
            if let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as? CommentViewCell{
                let currentComment = self.comments?[indexPath.row]
                self.idToIndexMapping[currentComment?.id ?? 0] = indexPath.row
                self.indexToCommentCount[indexPath.row] = currentComment?.upvoteCounts
                self.setUpCell(cell: cell, currentComment: currentComment)
                return cell
            } else {
                let cell = UITableViewCell(style: .default, reuseIdentifier: "placeholder")
                return cell
            }
        } else {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "placeholder")
            return cell
        }
    }
    
    func fetchComments(){
        Alamofire.request("\(apiUrl)/threads/\(threadId!)", method: .get).responseJSON {
            response in switch response.result {
            case .success(let JSON):
                var commentsArr = [Comment]()
                let response = JSON as! NSArray
                for commentResponse in response {
                    if let commentDictResponse = commentResponse as? Dictionary<String, Any> {
                        let comment = Comment(id: commentDictResponse["id"] as! Int,
                                              parentId: commentDictResponse["parentid"] as? Int,
                                              userId: commentDictResponse["userid"] as? Int,
                                              upvoteCounts: commentDictResponse["countUpvotes"] as? Int,
                                              body: commentDictResponse["body"] as? String,
                                              dateUpdated: commentDictResponse["dateupdated"] as? Date,
                                              dateCreated: commentDictResponse["datecreated"] as? Date,
                                              userDisplayName: commentDictResponse["displayname"] as? String,
                                              inResponseToId: commentDictResponse["inresponseto"] as? Int,
                                              didUpvote: commentDictResponse["didUpvote"] as? Bool)
                        commentsArr.append(comment)
                    }
                }
                self.comments = commentsArr.reversed()
                self.tableView.reloadData()
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    
    func addComment(body: String, reference: Comment?){
        let text = body
        if (text.characters.count > 1){
            var parameters: [String: Any]
            if let referenceComment = reference {
                parameters = ["text": text, "reference": referenceComment.id]
            } else {
                parameters = ["text": text]
            }
            
            if let thread = self.thread {
                let url = "\(apiUrl)/threads/\(thread.id)"
                Alamofire.request(url, method: .post,  parameters: parameters, encoding: JSONEncoding.default).responseJSON {
                    response in switch response.result {
                    case .success(let JSON):
                        if let _ = JSON as? Dictionary<String, AnyObject> {
                            self.fetchComments()
                            self.scrollToBottom()
                        }
                    case .failure(let error):
                        print("Request failed with error: \(error)")
                    }
                }
            }
        }
    }
    
    func reportComment(id: Int){
        let url = "\(apiUrl)/comments/\(id)/report"
        Alamofire.request(url, method: .post)
    }
    
    func reportThread(id: Int){
        let url = "\(apiUrl)/threads/\(id)/report"
        Alamofire.request(url, method: .post)
    }

    func upvoteComment(id: Int){
        let url = "\(apiUrl)/comments/\(id)/upvote"
        Alamofire.request(url, method: .post).responseJSON {
            response in switch response.result {
            case .success(let JSON):
                if let response = JSON as? Dictionary<String, AnyObject> {
                    if (response["affectedRows"] as? Int == 1) {
                        if let index = self.idToIndexMapping[id] {
                            if let cellView = (self.tableView.cellForRow(at: IndexPath(row: index, section: 1)) as? CommentViewCell){
                                let comment = self.comments?[index]
                                if let count = comment?.upvoteCounts {
                                    cellView.voteCountLabel.text = (count > 99) ? "99" : "\(count+2)"
                                    comment?.didUpvote = true
                                    comment?.upvoteCounts = count+1
                                    UIView.animate(withDuration: 0.5) {
                                        cellView.upvoteButton.alpha = 0.5
                                    }
                                }
                            }
                        }
                    }
                }
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    
    func downvoteComment(id: Int){
        let url = "\(apiUrl)/comments/\(id)/downvote"
        Alamofire.request(url, method: .post).responseJSON {
            response in switch response.result {
            case .success(let JSON):
                if let response = JSON as? Dictionary<String, AnyObject> {
                    if (response["affectedRows"] as? Int == 1) {
                        if let index = self.idToIndexMapping[id] {
                            if let cellView = (self.tableView.cellForRow(at: IndexPath(row: index, section: 1)) as? CommentViewCell){
                                let comment = self.comments?[index]
                                if let count = comment?.upvoteCounts {
                                    cellView.voteCountLabel.text = (count > 99) ? "99" : "\(count)"
                                    comment?.didUpvote = false
                                    comment?.upvoteCounts = count-1
                                    UIView.animate(withDuration: 0.5) {
                                        cellView.upvoteButton.alpha = 1.0
                                    }
                                }
                            }
                        }
                    }
                }
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    
    func setUpCell(cell: CommentViewCell, currentComment: Comment?){
        if (currentComment?.didUpvote)!{
            cell.upvoteButton.alpha = 0.5
        } else {
            cell.upvoteButton.alpha = 1.0
        }
        
        var count = 1
        if let savedCount = currentComment?.upvoteCounts {
            count += savedCount
        }
        
        cell.bodyTextLabel.text = currentComment?.body ?? "-"
        cell.authorTextLabel.text = currentComment?.userDisplayName ?? "user"
        cell.voteCountLabel.text = (count > 99) ? "99" : "\(count)"
        cell.upvoteButton.tag = currentComment?.id ?? 0
        cell.replyButton.tag = currentComment?.id ?? 0
        cell.upvoteButton.isEnabled = true
        setLayerForCell(cell: cell)
        
        if let stringId = UserDefaults.standard.object(forKey: "id") as? String {
            if let id = Int(stringId){
                if (currentComment?.userId! == id) {
                    cell.authorTextLabel.text = "\(cell.authorTextLabel.text!) ⭐️"
                    cell.upvoteButton.isEnabled = false
                    cell.upvoteButton.alpha = 0.5
                }
            }
        }
        cell.displayLinks()
    }
    
    func setUpBodyCell(cell: BodyViewCell){
        self.setLayerForBodyCell(cell: cell)
        if let stringId = UserDefaults.standard.object(forKey: "id") as? String {
            if let id = Int(stringId){
                if (self.thread?.userId == id) {
                    cell.authorTextLabel.text = "\(cell.authorTextLabel.text!) ⭐️"
                }
            }
        }
        cell.displayLinks()
        cell.titleLabel.text = self.thread?.title
    }
    
    func setLayerForCell(cell: CommentViewCell) {
        cell.bodyTextLabel.textColor = UIColor.white
        cell.authorTextLabel.textColor = UIColor.white
        cell.voteCountLabel.textColor = UIColor.white
        //cell.replyButton.setTitleColor(UIColor.white, for: .normal)
        cell.upvoteButton.setTitleColor(UIColor.white, for: .normal)
        cell.cellView.layer.cornerRadius = cornerRadius
        cell.cellView.layer.borderWidth = borderWidth
        cell.cellView.layer.borderColor = Theme.Dark.mainColor.cgColor
        cell.cellView.backgroundColor = Theme.Graphical.mainColor
    }
    
    func setLayerForBodyCell(cell: BodyViewCell){
        cell.titleLabel.textColor = UIColor.white
        cell.bodyTextLabel.textColor = UIColor.white
        cell.authorTextLabel.textColor = UIColor.white
        cell.cellView.layer.cornerRadius = cornerRadius
        cell.cellView.layer.borderWidth = borderWidth
        cell.cellView.layer.borderColor = Theme.Dark.mainColor.cgColor
        cell.cellView.backgroundColor = Theme.Dark.mainColor
    }
    
    func setUpRefreshView(){
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl!.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        self.tableView.refreshControl = self.refreshControl
        self.tableView.sendSubview(toBack: self.refreshControl!)
        //self.tableView?.insertSubview(self.refreshControl!, at: 0)
    }
    
    func refresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){ //a bit of a hack
            self.fetchComments()
            self.refreshControl?.layoutIfNeeded()
            self.refreshControl?.endRefreshing()
        }
    }
    
    //upvote button pressed
    @IBAction func upvote(sender: UIButton){
        let id = sender.tag
        let index = self.idToIndexMapping[id]
        let comment = self.comments?[index!]
        let didUpvote = comment?.didUpvote
        if didUpvote == true {
            self.downvoteComment(id: id)
        } else {
            self.upvoteComment(id: id)
        }
    }
    
    @IBAction func respond(sender: UIButton){
        let id = sender.tag
        if let index = self.idToIndexMapping[id] {
            self.referencing = self.comments?[index]
            if !((self.textView?.text.contains("@\((self.referencing!.userDisplayName)!):"))!){
                self.textView?.text = "@\((self.referencing!.userDisplayName)!): "+(self.textView?.text ?? "")
            }
        }
    }
    
    @IBAction func cellAdditionalButtonPressed(sender: UIButton){
        //show alert allowing to report
        let id = sender.tag
        self.showReportAlert(isCell: true, id: id)
    }
    
    @IBAction func threadAdditionalButtonPressed(sender: UIButton){
        self.showReportAlert(isCell: false, id: nil)
    }
    
    func post(sender: UIButton){
        if let text = self.textView?.text {
            if let referencedComment = referencing {
                if (text.contains(referencedComment.userDisplayName!)){
                    self.addComment(body: text, reference: referencedComment)
                } else {
                    self.addComment(body: text, reference: nil)
                }
            } else {
                self.addComment(body: text, reference: nil)
            }
        }
        self.textView?.text = ""
        self.textView?.resignFirstResponder()
    }
    
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        self.view.layoutIfNeeded()
    }
    
    func showReportAlert(isCell: Bool, id: Int?){
        var alertController: UIAlertController
        var reportAction: UIAlertAction
        if (isCell){
            alertController = UIAlertController(title: "Additional options", message: "Would you like to report this comment? Select 'report' if this comment is abusive or harmful", preferredStyle: .alert)
            reportAction = UIAlertAction(title: "Yes, report", style: .default) { (UIAlertAction) in
            self.reportComment(id: id!) }
        } else {
            alertController = UIAlertController(title: "Additional options", message: "Would you like to report this thread? Select 'report' if this thread is abusive or harmful", preferredStyle: .alert)
            reportAction = UIAlertAction(title: "Yes, report", style: .default) { (UIAlertAction) in
                self.reportThread(id: self.threadId!) }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) {(UIAlertAction) in }
        alertController.addAction(reportAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func setUpTextView(){
        
        let submitButton = UIButton()
        submitButton.addTarget(self, action: #selector(post), for: .touchUpInside)
        submitButton.setTitle("Submit", for: .normal)
        submitButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 14.0)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.backgroundColor = Theme.Graphical.mainColor
        submitButton.layer.cornerRadius = cornerRadius
        submitButton.layer.borderWidth = borderWidth
        submitButton.layer.borderColor = Theme.Dark.mainColor.cgColor

        self.textView = GrowingTextView()
        self.textView!.delegate = self
        self.textView!.layer.cornerRadius = cornerRadius
        self.textView!.maxLength = 500
        self.textView!.maxHeight = 100
        self.textView!.dataDetectorTypes = [.link]
        self.textView!.trimWhiteSpaceWhenEndEditing = true
        self.textView!.placeHolder = "Share your thoughts"
        self.textView!.placeHolderColor = UIColor(white: 0.8, alpha: 1.0)
        self.textView!.placeHolderLeftMargin = 5.0
        self.textView!.font = UIFont(name: "HelveticaNeue-Medium", size: 14.0)
        self.inputToolbar.addSubview(self.textView!)
        self.inputToolbar.addSubview(submitButton)
        
        self.textView!.translatesAutoresizingMaskIntoConstraints = false
        self.inputToolbar.translatesAutoresizingMaskIntoConstraints = false
        let views = ["textView": self.textView!, "submit": submitButton] as [String : Any]
        
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[textView]-4-[submit(60)]-8-|", options: [], metrics: nil, views: views)
        let vConstraintsText = NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[textView]-8-|", options: [], metrics: nil, views: views)
        let vConstraintsSubmit = NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[submit]-8-|", options: [], metrics: nil, views: views)
        inputToolbar.addConstraints(hConstraints)
        inputToolbar.addConstraints(vConstraintsText)
        inputToolbar.addConstraints(vConstraintsSubmit)
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5) {
            self.inputToolbar.alpha = 1.0
        }
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        self.tableView.addGestureRecognizer(tapGesture)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func keyboardWillChangeFrame(_ notification: Notification) {
        let before = bottomConstraint.constant
        let endFrame = ((notification as NSNotification).userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let growth = (self.textView?.frame.height)! - minHeight
        bottomConstraint.constant = view.frame.height - endFrame.origin.y
        tableBottomConstraint.constant = bottomConstraint.constant

        //keyboard becomes visible
        if (before < bottomConstraint.constant){
            bottomConstraint.constant -= (self.inputToolbar.frame.height-growth)
            tableBottomConstraint.constant += growth
        } else { //keyboard goes away
            tableBottomConstraint.constant = self.inputToolbar.frame.height
        }
        
        //TO DO: FIGURE OUT GROWTH8
        print(view.frame.height - endFrame.origin.y)
        self.tableView.contentInset.bottom = 44 + growth
        
        self.view.layoutIfNeeded()
        if (before < bottomConstraint.constant){
            //scroll to bottom
            self.scrollToBottom()
        }
    }
    
    func tapGestureHandler() {
        if (self.textView!.isFirstResponder){
            self.textView!.resignFirstResponder()
        }
    }
    
    func scrollToBottom(){
        let multiplier:CGFloat = 1.15
        if (self.tableView.contentSize.height > self.tableView.frame.size.height*multiplier){
            let scrollPoint = CGPoint(x: 0, y: 4+self.tableView.contentSize.height - self.tableView.frame.size.height)// not sure here + self.inputToolbar.frame.height)
            self.tableView.setContentOffset(scrollPoint, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    
        if (self.textView!.isFirstResponder){
            self.textView!.resignFirstResponder()
        }
    }

}


