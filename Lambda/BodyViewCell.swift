//
//  BodyViewCell.swift
//  Lambda
//
//  Created by Dmitry Pimenov on 6/24/17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import Foundation
import UIKit
import LinkLabel

class BodyViewCell: UITableViewCell, LinkLabelInteractionDelegate {
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var bodyTextLabel: LinkLabel!
    @IBOutlet weak var authorTextLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    func findLinks(string: String) -> [String: NSRange]{
        let urlRegEx = "((http|https)://)?(?:www\\.)?[\\w\\d\\-_]+\\.\\w{2,3}(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?"
        return matches(for: urlRegEx, in: string)
    }
    
    func displayLinks(){
        self.bodyTextLabel.interactionDelegate = self
        let text = self.bodyTextLabel.text
        let fullRange = NSMakeRange(0, (text! as NSString).length)
        let links = findLinks(string:text!)

        let attributedString = NSMutableAttributedString(string: text!)
        attributedString.addAttribute(NSFontAttributeName, value:UIFont(name: "HelveticaNeue-Medium", size: 14.0)! , range: fullRange)
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: fullRange)
        for key in links.keys {
            if (UIApplication.shared.canOpenURL(URL(string: key)!)){
                attributedString.addAttribute(NSLinkAttributeName, value: NSURL(string: key)!, range: links[key]!)
            }
        }
        self.bodyTextLabel.attributedText = attributedString
    }
    
    func linkLabelDidSelectLink(linkLabel: LinkLabel, url: NSURL) {
        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
    }

}
