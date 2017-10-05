//
//  File.swift
//  Lambda
//
//  Created by Dmitry Pimenov on 6/11/17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import Foundation

class Comment {
    var id: Int
    var parentId: Int?
    var userId: Int?
    var userDisplayName: String?
    var upvoteCounts: Int?
    var body: String?
    var dateUpdated: Date?
    var dateCreated: Date?
    var inResponseToId: Int?
    var didUpvote: Bool?
    
    init(id: Int, parentId: Int?, userId: Int?, upvoteCounts: Int?, body: String?, dateUpdated: Date?, dateCreated: Date?, userDisplayName: String?, inResponseToId: Int?, didUpvote: Bool?){
        self.id = id
        self.parentId = parentId
        self.userId = userId
        self.upvoteCounts = upvoteCounts
        self.body = body
        self.dateUpdated = dateUpdated
        self.dateCreated = dateCreated
        self.userDisplayName = userDisplayName
        self.inResponseToId = inResponseToId
        self.didUpvote = didUpvote
    }
    
}
