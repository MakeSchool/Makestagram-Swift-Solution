//
//  Post.swift
//  Makestagram
//
//  Created by Benjamin Encz on 5/25/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import Foundation
import Parse

class Post : PFObject, PFSubclassing {
  
  @NSManaged var imageFile: PFFile?
  @NSManaged var user: PFUser?

  var image: UIImage?
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
    let imageData = UIImageJPEGRepresentation(image, 0.8)
    let imageFile = PFFile(data: imageData)
    
    // 1
    photoUploadTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { () -> Void in
      UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
    }
    
    // 2
    imageFile.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
      // 3
      UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
    }
    
    // any uploaded post should be associated with the current user
    user = PFUser.currentUser()
    self.imageFile = imageFile
    saveInBackgroundWithBlock(nil)
  }
  
}