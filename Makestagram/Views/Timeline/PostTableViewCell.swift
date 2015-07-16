//
//  PostTableViewCell.swift
//  Makestagram
//
//  Created by Benjamin Encz on 5/26/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import Bond
import Parse

class PostTableViewCell: UITableViewCell {

  @IBOutlet weak var postImageView: UIImageView!
  @IBOutlet weak var likesIconImageView: UIImageView!
  @IBOutlet weak var likesLabel: UILabel!
  @IBOutlet weak var likeButton: UIButton!
  @IBOutlet weak var moreButton: UIButton!
    
  weak var timeline: TimelineViewController?
  
  var likeBond: Bond<[PFUser]?>!
  
  var post:Post? {
    didSet {
      // free memory of image stored with post that is no longer displayed
      if let oldValue = oldValue where oldValue != post {
        likeBond.unbindAll()
        postImageView.designatedBond.unbindAll()
        if (oldValue.image.bonds.count == 0) {
          oldValue.image.value = nil
        }
      }
      
      if let post = post {
        // bind the image of the post to the 'postImage' view
        post.image ->> postImageView
        
        // bind the likeBond that we defined earlier, to update like label and button when likes change
        post.likes ->> likeBond
      }
    }
  }
  
  //MARK: Initialization
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    likeBond = Bond<[PFUser]?>() { [unowned self] likeList in
      if let likeList = likeList {
        self.likesLabel.text = self.stringFromUserlist(likeList)
        self.likeButton.selected = contains(likeList, PFUser.currentUser()!)
        self.likesIconImageView.hidden = (likeList.count == 0)
      } else {
        // if there is no list of users that like this post, reset everything
        self.likesLabel.text = ""
        self.likeButton.selected = false
        self.likesIconImageView.hidden = true
      }
    }
  }
  
  // MARK: Button Callbacks
  
  @IBAction func moreButtonTapped(sender: AnyObject) {
    timeline?.showActionSheetForPost(post!)
  }
  
  // Technically this should live in the VC, decide whether or not we should keep it here for simplicity
  @IBAction func likeButtonTapped(sender: AnyObject) {
    post?.toggleLikePost(PFUser.currentUser()!)
  }
  
  //MARK: Helper functions
  
  // Generates a comma seperated list of usernames from an array (e.g. "User1, User2")
  func stringFromUserlist(userList: [PFUser]) -> String {
    let usernameList = userList.map { user in user.username! }
    let commaSeperatedUserList = ", ".join(usernameList)
    
    return commaSeperatedUserList
  }
  
}