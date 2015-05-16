//
//  TimelineComponent.swift
//  ConvenienceKit
//
//  Created by Benjamin Encz on 4/13/15.
//  Copyright (c) 2015 Benjamin Encz. All rights reserved.
//

import UIKit

public protocol TimelineComponentTarget: class {
  typealias ContentType
  
  var defaultRange: Range<Int> { get }
  var additionalRangeSize: Int { get }
  var tableView: UITableView! { get }
  func loadInRange(range: Range<Int>, completionBlock: ([ContentType]?) -> Void)
}

protocol Refreshable {
  func refresh(sender: AnyObject)
}

// Adds pull-to-refresh and lazy loading to a table view

public class TimelineComponent <T: Equatable, S: TimelineComponentTarget where S.ContentType == T> : Refreshable {
  
  weak var target: S?
  var refreshControl: UIRefreshControl
  
  var currentRange: Range<Int> = 0...0
  var loadedAllContent = false
  var targetTrampoline: TargetTrampoline!

  public var content: [T] = []
  
  public init(target: S) {
    self.target = target
    
    refreshControl = UIRefreshControl()
    target.tableView.insertSubview(refreshControl, atIndex:0)
    
    currentRange = target.defaultRange
    
    targetTrampoline = TargetTrampoline(target: self)
    
    refreshControl.addTarget(targetTrampoline, action: "refresh:", forControlEvents: .ValueChanged)
  }
  
  public func refresh(sender: AnyObject) {
    currentRange = target!.defaultRange
    
    target!.loadInRange(target!.defaultRange) { content in
      self.loadedAllContent = false
      self.content = content! as [T]
      self.refreshControl.endRefreshing()
      
      delay(0.5) {
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
  }
  
  public func removeObject(object: T) {
    ConvenienceKit.removeObject(object, fromArray: &self.content)
    currentRange.endIndex = self.currentRange.endIndex - 1
    target?.tableView.reloadData()
  }
  
  // MARK: Load more
  
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
  
  public func calledCellForRowAtIndexPath(indexPath: NSIndexPath) {
    if (indexPath.section == (currentRange.endIndex - 1) && !loadedAllContent) {
      loadMore()
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
