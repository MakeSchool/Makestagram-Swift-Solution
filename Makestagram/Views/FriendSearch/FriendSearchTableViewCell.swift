//
//  FriendSearchTableViewCell.swift
//  Makestagram
//
//  Created by Benjamin Encz on 6/2/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import Parse

protocol FriendSearchTableViewCellDelegate: class {
  func cell(cell: FriendSearchTableViewCell, didSelectFollowUser user: PFUser)
  func cell(cell: FriendSearchTableViewCell, didSelectUnfollowUser user: PFUser)
}

class FriendSearchTableViewCell: UITableViewCell {

  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var followButton: UIButton!
  weak var delegate: FriendSearchTableViewCellDelegate?
  
  var user: PFUser? {
    didSet {
      usernameLabel.text = user?.username
    }
  }
  
  var canFollow: Bool? = true {
    didSet {
      /* 
        Change the state of the follow button based on whether or not 
        it is possible to follow a user.
      */
      if let canFollow = canFollow {
        followButton.selected = !canFollow
      }
    }
  }
  
  @IBAction func followButtonTapped(sender: AnyObject) {
    if let canFollow = canFollow where canFollow == true {
      delegate?.cell(self, didSelectFollowUser: user!)
      self.canFollow = false
    } else {
      delegate?.cell(self, didSelectUnfollowUser: user!)
      self.canFollow = true
    }
  }
}