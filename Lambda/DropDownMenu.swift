//
//  DropDownMenu.swift
//  Lambda
//
//  Created by Dmitry Pimenov on 6/18/17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import UIKit

@objc public protocol DropDownMenuDelegate {
    func listTapped(sender: UIButton)
}

open class DropDownMenu: UIView {
    let buttonHeight: CGFloat = 40
    let offSet: CGFloat = 2
    
    var blurView: UIVisualEffectView?
    var primaryButton: UIButton?
    var lastSelectedIndex: Int = 0
    var lastSelectedId: Int = 4
    var delegate: DropDownMenuDelegate?
    var data: [Topic] = [Topic(dateCreated: nil, id: 4, displayName: "General discussion", dateUpdated: nil, parent: nil, body: nil)]
    var mappingIndexToId: [Int:Int] = [0:4]
    var menuView: UIScrollView?
    var parentView: UIView?
    var tapRecognizer: UITapGestureRecognizer?
    var preferredIndex: Int = 0
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func setUp(){
        self.primaryButton = UIButton(frame: self.bounds)
        self.primaryButton?.addTarget(self, action: #selector(hideOrShowMenu), for: .touchUpInside)
        self.primaryButton!.setTitle(self.data[self.preferredIndex].displayName, for: .normal)
        self.primaryButton!.titleLabel?.alpha = 0.0
        
        UIView.animate(withDuration: 0.5, animations: {
            self.primaryButton!.titleLabel?.alpha = 1.0
        }, completion: nil)
        
        self.lastSelectedIndex = self.preferredIndex
        self.lastSelectedId = self.data[self.preferredIndex].id
        self.styleButton(button: self.primaryButton!)
        self.addSubview(self.primaryButton!)
        
        self.tapRecognizer = UITapGestureRecognizer(target: self, action:#selector(handleTap(_:)))
        self.tapRecognizer!.numberOfTapsRequired = 1
        
        let heightApproximation = Double(CGFloat((offSet+buttonHeight)*CGFloat(data.count-1)))
        var heightProvided = heightApproximation
        if (heightApproximation > Double(self.parentView!.frame.height/2)){
            heightProvided = Double(self.parentView!.frame.height/1.3)
        }
        self.menuView = UIScrollView(frame: CGRect(x: self.frame.origin.x, y: self.frame.origin.y+self.frame.size.height
            , width: self.frame.size.width, height: CGFloat(heightProvided)))
        self.menuView?.contentSize = CGSize(width: self.frame.size.width, height: CGFloat(heightApproximation))
        self.backgroundColor = UIColor.clear
        self.menuView?.backgroundColor = UIColor.clear
        var count = 0
        if (data.count > 0){
            for i in 0 ..< data.count {
                if (i != self.preferredIndex){
                    addButton(data: data[i], index: i, shift:count)
                    count+=1
                }
                self.mappingIndexToId[i] = data[i].id
            }
        }
    }
    
    func addButton(data: Topic, index: Int, shift: Int){
        let currentX: CGFloat = 0.0
        let currentY: CGFloat = (buttonHeight+offSet)*CGFloat(shift)+offSet
        let width = self.frame.width
        let button = UIButton(frame: CGRect(x: currentX, y: currentY, width: width, height: buttonHeight))
        self.styleButton(button: button)
        button.setTitle(data.displayName, for: .normal)
        button.tag = index
        button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        self.menuView?.addSubview(button)
    }
    
    func handleTap(_ sender: UITapGestureRecognizer) {
        if(sender.state == .recognized)
        {
            let point = sender.location(in: parentView)
            if (!self.frame.contains(point)){
                hideMenu()
            }
        }
    }
    
    func buttonPressed(_ sender: UIButton) {
        self.hideMenu()
        let copy = self.lastSelectedIndex
        self.lastSelectedIndex = sender.tag
        self.lastSelectedId = self.mappingIndexToId[sender.tag]!
        sender.tag = copy
        sender.setTitle(self.data[sender.tag].displayName, for: .normal)
        self.primaryButton?.setTitle(self.data[self.lastSelectedIndex].displayName, for: .normal)
        //swap
        delegate?.listTapped(sender: sender)
    }
    
    func hideOrShowMenu(){
        if (self.menuView?.superview != nil){
            self.hideMenu()
        } else {
            self.showMenu()
        }
    }
    
    func hideMenu(){
        hideBlur()
        self.menuView?.removeFromSuperview()
        if (self.parentView?.gestureRecognizers?.contains(self.tapRecognizer!))! {
            self.parentView?.removeGestureRecognizer(self.tapRecognizer!)
        }
    }
    
    func showMenu(){
        showBlur()
        self.parentView?.addSubview(self.menuView!)
        self.parentView?.addGestureRecognizer(self.tapRecognizer!)
    }
    
    func showBlur(){
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.regular)
        self.blurView = UIVisualEffectView(effect: blurEffect)
        self.blurView!.frame = self.parentView!.bounds
        self.blurView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.parentView?.addSubview(self.blurView!)
        self.parentView?.bringSubview(toFront: self)
    }
    
    func hideBlur(){
        self.blurView?.removeFromSuperview()
    }
    
    func styleButton(button: UIButton){
        button.titleLabel?.font = UIFont(name: "Georgia", size: 17)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.backgroundColor = Theme.Graphical.mainColor
        button.titleLabel?.textColor = UIColor.white
        button.layer.borderColor = Theme.Dark.mainColor.cgColor
        button.layer.borderWidth = borderWidth
        button.layer.cornerRadius = cornerRadius
    }
}
