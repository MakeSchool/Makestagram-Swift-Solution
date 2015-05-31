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
  
  // Following Relation
  static let ParseFollowClass       = "Follow"
  static let ParseFollowFromUser    = "fromUser"
  static let ParseFollowToUser      = "toUser"
  
  // Like Relation
  static let ParseLikeClass         = "Like"
  static let ParseLikeToPost        = "toPost"
  static let ParseLikeFromUser      = "fromUser"
  
  // Post Relation
  static let ParsePostUser          = "user"
  static let ParsePostCreatedAt     = "createdAt"
  
  // Flagged Content Relation
  static let ParseFlaggedContentClass    = "FlaggedContent"
  static let ParseFlaggedContentFromUser = "fromUser"
  static let ParseFlaggedContentToPost   = "toPost"
  
  // User Relation
  static let ParseUserUsername      = "username"
  
  // MARK: Timeline
  
  static func timelineRequestforCurrentUser(range: Range<Int>, completionBlock: PFArrayResultBlock) {
    let followingQuery = PFQuery(className: ParseFollowClass)
    followingQuery.whereKey(ParseLikeFromUser, equalTo:PFUser.currentUser()!)
    
    let postsFromFollowedUsers = Post.query()
    postsFromFollowedUsers!.whereKey(ParsePostUser, matchesKey: ParseFollowToUser, inQuery: followingQuery)
    
    let postsFromThisUser = Post.query()
    postsFromThisUser!.whereKey(ParsePostUser, equalTo: PFUser.currentUser()!)
    
    let query = PFQuery.orQueryWithSubqueries([postsFromFollowedUsers!, postsFromThisUser!])
    query.includeKey(ParsePostUser)
    query.orderByDescending(ParsePostCreatedAt)
    
    query.skip = range.startIndex
    query.limit = range.endIndex - range.startIndex
    
    query.findObjectsInBackgroundWithBlock(completionBlock)
  }
  
  // MARK: Likes
  
  static func likePost(user: PFUser, post: Post) {
    let likeObject = PFObject(className: ParseLikeClass)
    likeObject.setObject(user, forKey: ParseLikeFromUser)
    likeObject.setObject(post, forKey: ParseLikeToPost)
    
    likeObject.saveInBackgroundWithBlock(nil)
  }
  
  static func unlikePost(user: PFUser, post: Post) {
    let query = PFQuery(className: ParseLikeClass)
    query.whereKey(ParseLikeFromUser, equalTo: user)
    query.whereKey(ParseLikeToPost, equalTo: post)
    
    query.findObjectsInBackgroundWithBlock {
      (results: [AnyObject]?, error: NSError?) -> Void in
        if let results = results as? [PFObject] {
          for object in results {
            object.deleteInBackgroundWithBlock(nil)
          }
        }
    }
  }
  
  static func likesForPost(post: Post, completionBlock: PFArrayResultBlock) {
    let query = PFQuery(className: ParseLikeClass)
    query.whereKey(ParseLikeToPost, equalTo: post)
    query.includeKey(ParseLikeFromUser)
    
    query.findObjectsInBackgroundWithBlock(completionBlock)
  }
}

extension PFObject : Equatable {
  
}

public func ==(lhs: PFObject, rhs: PFObject) -> Bool {
  return lhs.objectId == rhs.objectId
}