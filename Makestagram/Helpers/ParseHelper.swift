//
//  ParseHelper.swift
//  Makestagram
//
//  Created by Benjamin Encz on 5/27/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import Foundation
import Parse

class ParseHelper {
  
  static func timelineRequestforCurrentUser(completionBlock: PFArrayResultBlock) {
    let followingQuery = PFQuery(className: "Follow")
    followingQuery.whereKey("fromUser", equalTo:PFUser.currentUser()!)
    
    let postsFromFollowedUsers = Post.query()
    postsFromFollowedUsers!.whereKey("user", matchesKey: "toUser", inQuery: followingQuery)
    
    let postsFromThisUser = Post.query()
    postsFromThisUser!.whereKey("user", equalTo: PFUser.currentUser()!)
    
    let query = PFQuery.orQueryWithSubqueries([postsFromFollowedUsers!, postsFromThisUser!])
    query.includeKey("user")
    query.orderByDescending("createdAt")
    
    query.findObjectsInBackgroundWithBlock(completionBlock)
  }
  
}
