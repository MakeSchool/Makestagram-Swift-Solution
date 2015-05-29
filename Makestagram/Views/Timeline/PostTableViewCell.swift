//
//  PostTableViewCell.swift
//  Makestagram
//
//  Created by Benjamin Encz on 5/26/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import Bond

class PostTableViewCell: UITableViewCell {

  @IBOutlet weak var postImageView: UIImageView!
  @IBOutlet weak var likesIconImageView: UIImageView!
  @IBOutlet weak var likesLabel: UILabel!
  @IBOutlet weak var likeButton: UIButton!
  @IBOutlet weak var moreButton: UIButton!
  
  var post:Post? {
    didSet {
      if let post = post {
        // bind the image of the post to the 'postImage' view
        post.image ->> postImageView
      }
    }
  }
  
  @IBAction func moreButtonTapped(sender: AnyObject) {
    
  }
  
  @IBAction func likeButtonTapped(sender: AnyObject) {
    
  }
  
}