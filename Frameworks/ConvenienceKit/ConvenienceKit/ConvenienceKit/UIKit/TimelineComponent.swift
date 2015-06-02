//
//  TimelineComponent.swift
//  ConvenienceKit
//
//  Created by Benjamin Encz on 4/13/15.
//  Copyright (c) 2015 Benjamin Encz. All rights reserved.
//

import UIKit

/**
  This protocol needs to be implemented by any class that wants to be the target
  of the Timeline Component.
*/
public protocol TimelineComponentTarget: class {
  typealias ContentType
  
  /// Defines the range of the timeline that gets loaded initially.
  var defaultRange: Range<Int> { get }
  /** 
    Defines the additional amount of items that get loaded
    subsequently when a user reaches the last entry.
  */
  var additionalRangeSize: Int { get }
  /// A reference to the TableView to which the Timeline Component is applied.
  var tableView: UITableView! { get }
  /**
    This method should load the items within the specified range and call the 
    `completionBlock`, with the items as argument, upon completion.
  */
  func loadInRange(range: Range<Int>, completionBlock: ([ContentType]?) -> Void)
}

protocol Refreshable {
  func refresh(sender: AnyObject)
}

/**
Adds a Pull-To-Refresh mechanism and endless scrolling behavior to classes that own
a `UITableView`.

Note that this class will handle storage of the content that is relevant to the TableView's Data Source in the 
`content` property.

Apply following steps to use this class:

1. Implement the `TimelineComponentTarget` protocol
2. Call the `loadInitialIfRequired()` when you want to load the Data Source's content for the first time
3. Call `targetWillDisplayEntry(entryIndex:)` when a cell becomes visible
*/
public class TimelineComponent <T: Equatable, S: TimelineComponentTarget where S.ContentType == T> : Refreshable {
  
  weak var target: S?
  var refreshControl: UIRefreshControl
  
  var currentRange: Range<Int> = 0...0
  var loadedAllContent = false
  var targetTrampoline: TargetTrampoline!
  
  
  // MARK: Public Interface
  
  /// Stores the items that should be displayed in the Table View
  public var content: [T] = []

  /**
    Creates a Timeline Component and connects it to its target.
  
    :param: target The class on which the Timeline Component shall operate
  */
  public init(target: S) {
    self.target = target
    
    refreshControl = UIRefreshControl()
    target.tableView.insertSubview(refreshControl, atIndex:0)
    
    currentRange = target.defaultRange
    
    targetTrampoline = TargetTrampoline(target: self)
    
    refreshControl.addTarget(targetTrampoline, action: "refresh:", forControlEvents: .ValueChanged)
  }
  
  /**
    Removes an object from the `content` of the Timeline Component
  
    :param: object The object that shall be removed.
  */
  public func removeObject(object: T) {
    ConvenienceKit.removeObject(object, fromArray: &self.content)
    currentRange.endIndex = self.currentRange.endIndex - 1
    target?.tableView.reloadData()
  }
  
  /**
    Triggers an initial request for data, if no data has been loaded so far.
  */
  public func loadInitialIfRequired() {
    // if no posts are currently loaded, load the default range
    if (content == []) {
      target!.loadInRange(target!.defaultRange) { posts in
        self.content = posts ?? []
        self.target!.tableView.reloadData()
      }
    }
  }
  
  /**
    Should be called whenever a cell becomes visible. This allows the Timeline Component
    to decide when to load additional items.
  
    :param: entryIndex The index of the cell that became visible
  */
  public func targetWillDisplayEntry(entryIndex: Int) {
    if (entryIndex == (currentRange.endIndex - 1) && !loadedAllContent) {
      loadMore()
    }
  }
  
  // MARK: Internal Interface
  
  internal func refresh(sender: AnyObject) {
    currentRange = target!.defaultRange
    
    target!.loadInRange(target!.defaultRange) { content in
      self.loadedAllContent = false
      self.content = content! as [T]
      self.refreshControl.endRefreshing()
      
      UIView.transitionWithView(self.target!.tableView,
        duration: 0.35,
        options: .TransitionCrossDissolve,
        animations:
        { () -> Void in
          self.target!.tableView.reloadData()
          self.target!.tableView.contentOffset = CGPoint(x: 0, y: 0)
        },
        completion: nil);
    }
  }
  
  func loadMore() {
    let additionalRange = Range(start: currentRange.endIndex, end: currentRange.endIndex + target!.additionalRangeSize)
    currentRange = Range(start: currentRange.startIndex, end: additionalRange.endIndex)
    
    target!.loadInRange(additionalRange) { posts in
      let newPosts = posts
      
      if (newPosts!.count == 0) {
        self.loadedAllContent = true
      }
      
      self.content = self.content + newPosts!
      self.target!.tableView.reloadData()
    }
  }
  
}

/**
Provides a class that can be exposed to Objective-C because it doesn't use generics.
The only purpose of this class is to expose "refresh" and call it on the Swift class
that uses Generics.
*/
class TargetTrampoline: NSObject, Refreshable {
  
  let target: Refreshable
  
  init(target: Refreshable) {
    self.target = target
  }
  
  func refresh(sender: AnyObject) {
    target.refresh(self)
  }
}