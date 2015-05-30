//
//  Post.swift
//  Makestagram
//
//  Created by Benjamin Encz on 5/25/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import Foundation
import Parse
import Bond

class Post : PFObject, PFSubclassing {
  
  @NSManaged var imageFile: PFFile?
  @NSManaged var user: PFUser?

  var image: Dynamic<UIImage?> = Dynamic(nil)
  var likes =  Dynamic<[PFUser]?>(nil)
  var photoUploadTask: UIBackgroundTaskIdentifier?
  
  //MARK: PFSubclassing Protocol
  
  static func parseClassName() -> String {
    return "Post"
  }
  
  override init () {
    super.init()
  }
  
  override class func initialize() {
    var onceToken : dispatch_once_t = 0;
    dispatch_once(&onceToken) {
      // inform Parse about this subclass
      self.registerSubclass()
    }
  }
  
  //MARK: Parse logic
  
  func uploadPost() {
    let imageData = UIImageJPEGRepresentation(image.value, 0.8)
    let imageFile = PFFile(data: imageData)
    
    photoUploadTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { () -> Void in
      UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
    }
    
    imageFile.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
      UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
    }
    
    // any uploaded post should be associated with the current user
    user = PFUser.currentUser()
    self.imageFile = imageFile
    saveInBackgroundWithBlock(nil)
  }
  
  func downloadImage() {
    // if image is not downloaded yet, get it
    if (image.value == nil) {
      imageFile?.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) -> Void in
        if let data = data {
          let image = UIImage(data: data, scale:1.0)!
          self.image.value = image
        }
      }
    }
  }
  
  func fetchLikes() {
    if (likes.value != nil) {
      return
    }
    
    ParseHelper.likesForPost(self, completionBlock: { (var likes: [AnyObject]?, error: NSError?) -> Void in
      // filter likes that are from users that no longer exist
      likes = likes?.filter { like in like[ParseHelper.ParseLikeFromUser] != nil }

      self.likes.value = likes?.map { like in
        let like = like as! PFObject
        let fromUser = like[ParseHelper.ParseLikeFromUser] as! PFUser
        
        return fromUser
      }
    })
  }
  
  //MARK: Likes
  
  func doesUserLikePost(user: PFUser) -> Bool {
    if let likes = likes.value {
      return contains(likes, user)
    } else {
      return false
    }
  }
  
  func toggleLikePost(user: PFUser) {
    if (doesUserLikePost(user)) {
      // if image is liked, unlike it now
      likes.value = likes.value?.filter { $0 != user }
      ParseHelper.unlikePost(user, post: self)
    } else {
      // if this image is not liked yet, like it now
      likes.value?.append(user)
      ParseHelper.likePost(user, post: self)
    }
  }
  
}