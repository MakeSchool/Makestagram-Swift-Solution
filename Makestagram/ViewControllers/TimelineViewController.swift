//
//  TimelineViewController.swift
//  Makestagram
//
//  Created by Benjamin Encz on 5/21/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import Parse

class TimelineViewController: UIViewController {
  @IBOutlet weak var tableView: UITableView!
  
  var photoTakingHelper: PhotoTakingHelper?
  var posts: [Post] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.tabBarController?.delegate = self
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    let followingQuery = PFQuery(className: "Follow")
    followingQuery.whereKey("fromUser", equalTo:PFUser.currentUser()!)
    
    let postsFromFollowedUsers = Post.query()
    postsFromFollowedUsers!.whereKey("user", matchesKey: "toUser", inQuery: followingQuery)
    
    let postsFromThisUser = Post.query()
    postsFromThisUser!.whereKey("user", equalTo: PFUser.currentUser()!)
    
    let query = PFQuery.orQueryWithSubqueries([postsFromFollowedUsers!, postsFromThisUser!])
    query.includeKey("user")
    query.orderByDescending("createdAt")
    
    query.findObjectsInBackgroundWithBlock {(result: [AnyObject]?, error: NSError?) -> Void in
      self.posts = result as? [Post] ?? []
      self.tableView.reloadData()
    }
  }
  
  // MARK: View callbacks
  
  func takePhoto() {
    // instantiate photo taking class, provide callback for when photo is selected
    photoTakingHelper =
      PhotoTakingHelper(viewController: self.tabBarController!) { (image: UIImage?) in
        let post = Post()
        post.image = image
        post.uploadPost()
    }
  }
  
}

// MARK: Tab Bar Delegate

extension TimelineViewController: UITabBarControllerDelegate {
  
  func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
    if (viewController is PhotoViewController) {
      takePhoto()
      return false
    } else {
      return true
    }
  }
  
}

// MARK: TableViewDataSource

extension TimelineViewController: UITableViewDataSource {
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return posts.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! UITableViewCell

    cell.textLabel!.text = "Post"

    return cell
  }
  
}