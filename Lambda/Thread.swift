//
//  Thread.swift
//  Lambda
//
//  Created by Dmitry Pimenov on 6/10/17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import Foundation

class Thread {
    var dateCreated: Date?
    var id: Int
    var title: String?
    var displayName: String?
    var dateUpdated: Date?
    var parentId: Int?
    var body: String?
    var userId: Int?
    var didUpvote: Bool?
    var countUpvotes: Int?
    var countComments: Int?
    
    init(dateCreated: Date?, id: Int, title: String?, displayName: String?, dateUpdated: Date?, parentId: Int?, body: String?, userId: Int?, didUpvote: Bool?, countUpvotes: Int?, countComments: Int?){
        self.dateCreated = dateCreated
        self.id = id
        self.title = title
        self.displayName = displayName
        self.dateUpdated = dateUpdated
        self.parentId = parentId
        self.body = body
        self.userId = userId
        self.didUpvote = didUpvote
        self.countUpvotes = countUpvotes
        self.countComments = countComments
    }
}
