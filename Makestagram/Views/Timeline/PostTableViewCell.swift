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
  
  var post:Post? {
    didSet {
      if let post = post {
        // bind the image of the post to the 'postImage' view
        post.image ->> postImageView
      }
    }
  }
}