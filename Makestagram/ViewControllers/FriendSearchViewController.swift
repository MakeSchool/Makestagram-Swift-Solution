//
//  FriendSearchViewController.swift
//  Makestagram
//
//  Created by Benjamin Encz on 5/21/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import ConvenienceKit
import Parse

class FriendSearchViewController: UIViewController {
  
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var tableView: UITableView!
  
  // stores all the users that match the current search query
  var users: [PFUser]?
  
  /*
    This is a local cache. It stores all the users this user is following.
    It is used to update the UI immediately upon user interaction, instead of waiting
    for a server response.
  */
  var followingUsers: [PFUser]? {
    didSet {
      /**
      the list of following users may be fetched after the tableView has displayed
      cells. In this case, we reload the data to reflect "following" status
      */
      tableView.reloadData()
    }
  }
  
  // the current parse query
  var query: PFQuery? {
    didSet {
      // whenever we assign a new query, cancel any previous requests
      oldValue?.cancel()
    }
  }
  
  // this view can be in two different states
  enum State {
    case DefaultMode
    case SearchMode
  }
  
  // whenever the state changes, perform one of the two queries and update the list
  var state: State = .DefaultMode {
    didSet {
      switch (state) {
      case .DefaultMode:
        query = ParseHelper.allUsers(updateList)
        
      case .SearchMode:
        let searchText = searchBar?.text ?? ""
         query = ParseHelper.searchUsers(searchText, completionBlock:updateList)
      }
    }
  }
  
  // MARK: Update userlist
  
  /** 
    Is called as the completion block of all queries.
    As soon as a query completes, this method updates the Table View.
  */
  func updateList(results: [AnyObject]?, error: NSError?) {
    self.users = results as? [PFUser] ?? []
    self.tableView.reloadData()
    
    if let error = error {
      ErrorHandling.defaultErrorHandler(error)
    }
  }
  
  // MARK: View Lifecycle
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    state = .DefaultMode
    
    // fill the cache of a user's followees
    ParseHelper.getFollowingUsersForUser(PFUser.currentUser()!) {
      (results: [AnyObject]?, error: NSError?) -> Void in
        if let error = error {
          ErrorHandling.defaultErrorHandler(error)
        }
      
        let relations = results as? [PFObject] ?? []
        // use map to extract the User from a Follow object
        self.followingUsers = relations.map {
          $0.objectForKey(ParseHelper.ParseFollowToUser) as! PFUser
        }
        
        if let error = error {
          // Call the default error handler in case of an Error
          ErrorHandling.defaultErrorHandler(error)
        }
    }
  }
  
}

// MARK: TableView Data Source

extension FriendSearchViewController: UITableViewDataSource {
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.users?.count ?? 0
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("UserCell") as! FriendSearchTableViewCell
    
    let user = users![indexPath.row]
    cell.user = user
    
    if let followingUsers = followingUsers {
      // check if current user is already following displayed user
      // change button appereance based on result
      cell.canFollow = !contains(followingUsers, user)
    }
    
    cell.delegate = self
    
    return cell
  }
}

// MARK: Searchbar Delegate

extension FriendSearchViewController: UISearchBarDelegate {
  
  func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
    searchBar.setShowsCancelButton(true, animated: true)
    state = .SearchMode
  }
  
  func searchBarCancelButtonClicked(searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
    searchBar.text = ""
    searchBar.setShowsCancelButton(false, animated: true)
    state = .DefaultMode
  }
  
  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    ParseHelper.searchUsers(searchText, completionBlock:updateList)
  }
  
}

// MARK: FriendSearchTableViewCell Delegate

extension FriendSearchViewController: FriendSearchTableViewCellDelegate {
  
  func cell(cell: FriendSearchTableViewCell, didSelectFollowUser user: PFUser) {
    ParseHelper.addFollowRelationshipFromUser(PFUser.currentUser()!, toUser: user)
    // update local cache
    followingUsers?.append(user)
  }
  
  func cell(cell: FriendSearchTableViewCell, didSelectUnfollowUser user: PFUser) {
    if var followingUsers = followingUsers {
      ParseHelper.removeFollowRelationshipFromUser(PFUser.currentUser()!, toUser: user)
      // update local cache
      removeObject(user, fromArray: &followingUsers)
      self.followingUsers = followingUsers
    }
  }
  
}

// MARK: Style

extension FriendSearchViewController {
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}
