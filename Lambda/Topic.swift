//
//  Topic.swift
//  Lambda
//
//  Created by Dmitry Pimenov on 6/10/17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import Foundation

class Topic {
    var dateCreated: Date?
    var id: Int
    var displayName: String?
    var dateUpdated: Date?
    var parent: String?
    var body: String?
    
    init(dateCreated: Date?, id: Int, displayName: String?, dateUpdated: Date?, parent: String?, body: String?){
        self.dateCreated = dateCreated
        self.id = id
        self.displayName = displayName
        self.dateUpdated = dateUpdated
        self.parent = parent
        self.body = body
    }
}
