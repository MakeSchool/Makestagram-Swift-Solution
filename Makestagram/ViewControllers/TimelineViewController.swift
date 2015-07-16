//
//  TimelineViewController.swift
//  Makestagram
//
//  Created by Benjamin Encz on 5/21/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import Parse
import ConvenienceKit

class TimelineViewController: UIViewController, TimelineComponentTarget {
  @IBOutlet weak var tableView: UITableView!
  
  var photoTakingHelper: PhotoTakingHelper?
  
  // Timeline Component Protocol
  let defaultRange = 0...4
  let additionalRangeSize = 5
  var timelineComponent: TimelineComponent<Post, TimelineViewController>!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    timelineComponent = TimelineComponent(target: self)
    self.tabBarController?.delegate = self
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
  
    timelineComponent.loadInitialIfRequired()
  }
  
  // MARK: TimelineComponentTarget implementation
  
  func loadInRange(range: Range<Int>, completionBlock: ([Post]?) -> Void) {
    ParseHelper.timelineRequestforCurrentUser(range) {
      (result: [AnyObject]?, error: NSError?) -> Void in
        if let error = error {
          ErrorHandling.defaultErrorHandler(error)
        }
      
        let posts = result as? [Post] ?? []
        completionBlock(posts)
    }
  }
  
  // MARK: View callbacks
  
  func takePhoto() {
    // instantiate photo taking class, provide callback for when photo is selected
    photoTakingHelper =
      PhotoTakingHelper(viewController: self.tabBarController!) { (image: UIImage?) in
        let post = Post()
        post.image.value = image!
        post.uploadPost()
    }
  }
    
  // MARK: UIActionSheets

  func showActionSheetForPost(post: Post) {
      if (post.user == PFUser.currentUser()) {
          showDeleteActionSheetForPost(post)
      } else {
          showFlagActionSheetForPost(post)
      }
  }
  
  func showDeleteActionSheetForPost(post: Post) {
    let alertController = UIAlertController(title: nil, message: "Do you want to delete this post?", preferredStyle: .ActionSheet)
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
    alertController.addAction(cancelAction)
    
    let destroyAction = UIAlertAction(title: "Delete", style: .Destructive) { (action) in
      post.deleteInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
        if (success) {
          self.timelineComponent.removeObject(post)
        } else {
          // restore old state
          self.timelineComponent.refresh(self)
        }
      })
    }
    alertController.addAction(destroyAction)
    
    self.presentViewController(alertController, animated: true, completion: nil)
  }
  
  func showFlagActionSheetForPost(post: Post) {
    let alertController = UIAlertController(title: nil, message: "Do you want to flag this post?", preferredStyle: .ActionSheet)
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
    alertController.addAction(cancelAction)
    
    let destroyAction = UIAlertAction(title: "Flag", style: .Destructive) { (action) in
      post.flagPost(PFUser.currentUser()!)
    }
    
    alertController.addAction(destroyAction)
    
    self.presentViewController(alertController, animated: true, completion: nil)
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
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return self.timelineComponent.content.count
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostTableViewCell

    let post = timelineComponent.content[indexPath.section]
    post.downloadImage()
    post.fetchLikes()
    cell.post = post
    cell.timeline = self
    
    return cell
  }
  
}

// MARK: TableViewDelegate

extension TimelineViewController: UITableViewDelegate {
  
  func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    
    timelineComponent.targetWillDisplayEntry(indexPath.section)
  }
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerCell = tableView.dequeueReusableCellWithIdentifier("PostHeader") as! PostSectionHeaderView
    
    let post = self.timelineComponent.content[section]
    headerCell.post = post
    
    return headerCell
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 40
  }
  
}

// MARK: Style

extension TimelineViewController {
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}