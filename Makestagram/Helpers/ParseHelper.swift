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
    
    likeObject.saveInBackgroundWithBlock(ErrorHandling.errorHandlingCallback)
  }
  
  static func unlikePost(user: PFUser, post: Post) {
    let query = PFQuery(className: ParseLikeClass)
    query.whereKey(ParseLikeFromUser, equalTo: user)
    query.whereKey(ParseLikeToPost, equalTo: post)
    
    query.findObjectsInBackgroundWithBlock {
      (results: [AnyObject]?, error: NSError?) -> Void in
        if let error = error {
          ErrorHandling.defaultErrorHandler(error)
        }
      
        if let results = results as? [PFObject] {
          for likes in results {
            likes.deleteInBackgroundWithBlock(ErrorHandling.errorHandlingCallback)
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
  
  //MARK: Flagging
  
  static func flagPost(user: PFUser, post: Post) {
    let flagObject = PFObject(className: ParseFlaggedContentClass)
    flagObject.setObject(user, forKey: ParseFlaggedContentFromUser)
    flagObject.setObject(post, forKey: ParseFlaggedContentToPost)
    
    let ACL = PFACL(user: PFUser.currentUser()!)
    ACL.setPublicReadAccess(true)
    flagObject.ACL = ACL
    
    //TODO: add error handling
    flagObject.saveInBackgroundWithBlock(ErrorHandling.errorHandlingCallback)
  }
  
  // MARK: Following
  
  /**
    Fetches all users that the provided user is following.
    
    :param: user The user who's followees you want to retrive
    :param: completionBlock The completion block that is called when the query completes
  */
  static func getFollowingUsersForUser(user: PFUser, completionBlock: PFArrayResultBlock) {
    let query = PFQuery(className: ParseFollowClass)
    
    query.whereKey(ParseFollowFromUser, equalTo:user)
    query.findObjectsInBackgroundWithBlock(completionBlock)
  }
  
  /**
    Establishes a follow relationship between two users.
  
    :param: user    The user that is following
    :param: toUser  The user that is being followed
  */
  static func addFollowRelationshipFromUser(user: PFUser, toUser: PFUser) {
    let followObject = PFObject(className: ParseFollowClass)
    followObject.setObject(user, forKey: ParseFollowFromUser)
    followObject.setObject(toUser, forKey: ParseFollowToUser)
    
    followObject.saveInBackgroundWithBlock(ErrorHandling.errorHandlingCallback)
  }
  
  /**
    Deletes a follow relationship between two users.
    
    :param: user    The user that is following
    :param: toUser  The user that is being followed
  */
  static func removeFollowRelationshipFromUser(user: PFUser, toUser: PFUser) {
    let query = PFQuery(className: ParseFollowClass)
    query.whereKey(ParseFollowFromUser, equalTo:user)
    query.whereKey(ParseFollowToUser, equalTo: toUser)
    
    query.findObjectsInBackgroundWithBlock {
      (results: [AnyObject]?, error: NSError?) -> Void in
        if let error = error {
          ErrorHandling.defaultErrorHandler(error)
        }
      
        let results = results as? [PFObject] ?? []
      
        for followRelationshop in results {
          followRelationshop.deleteInBackgroundWithBlock(ErrorHandling.errorHandlingCallback)
        }
    }
  }
  
  // MARK: Users
  
  /**
    Fetch all users, except the one that's currently signed in.
    Limits the amount of users returned to 20.
  
    :param: completionBlock The completion block that is called when the query completes
  
    :returns: The generated PFQuery 
  */
  static func allUsers(completionBlock:PFArrayResultBlock) -> PFQuery {
    let query = PFUser.query()!
    // exclude the current user
    query.whereKey(ParseHelper.ParseUserUsername,
      notEqualTo: PFUser.currentUser()!.username!)
    query.orderByAscending(ParseHelper.ParseUserUsername)
    query.limit = 20
    
    query.findObjectsInBackgroundWithBlock(completionBlock)
    
    return query
  }
  
  /**
  Fetch users who's username matches the provided search term.
  
  :param: searchText The text that should be used to search for users
  :param: completionBlock The completion block that is called when the query completes
  
  :returns: The generated PFQuery
  */
  static func searchUsers(searchText: String, completionBlock: PFArrayResultBlock)
    -> PFQuery {
    /*
      NOTE: We are using a Regex to allow for a case insensetive compare of usernames.
      Regex can be slow on large datasets. For large amount of data it's better to store 
      lowercased username in a separate column and perform a regular string compare.
    */
    let query = PFUser.query()!.whereKey(ParseHelper.ParseUserUsername,
      matchesRegex: searchText, modifiers: "i")
    
    query.whereKey(ParseHelper.ParseUserUsername,
      notEqualTo: PFUser.currentUser()!.username!)
      
    query.orderByAscending(ParseHelper.ParseUserUsername)
    query.limit = 20
    
    query.findObjectsInBackgroundWithBlock(completionBlock)
    
    return query
  }

  
}

extension PFObject : Equatable {
  
}

public func ==(lhs: PFObject, rhs: PFObject) -> Bool {
  return lhs.objectId == rhs.objectId
}