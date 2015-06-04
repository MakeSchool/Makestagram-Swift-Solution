//
//  NSCacheSwift.swift
//  ConvenienceKit
//
//  Created by Benjamin Encz on 6/4/15.
//  Copyright (c) 2015 Benjamin Encz. All rights reserved.
//

import Foundation

public class NSCacheSwift<T, U> {
  
  private let cache: NSCache
  
  public var delegate: NSCacheDelegate? {
    get {
      return cache.delegate
    }
    set {
      cache.delegate = delegate
    }
  }
  
  public var name: String {
    get {
      return cache.name
    }
    set {
      cache.name = name
    }
  }
  
  public var totalCostLimit: Int {
    get {
      return cache.totalCostLimit
    }
    set {
      cache.totalCostLimit = totalCostLimit
    }
  }
  
  public var countLimit: Int {
    get {
      return cache.countLimit
    }
    set {
      cache.countLimit = countLimit
    }
  }
  
  public var evictsObjectsWithDiscardedContent: Bool {
    get {
      return cache.evictsObjectsWithDiscardedContent
    }
    set {
      return cache.evictsObjectsWithDiscardedContent = evictsObjectsWithDiscardedContent
    }
  }
  
  public init() {
    cache = NSCache()
  }
  
  // MARK: Public Interface

  public func objectForKey(key: T) -> U? {
    return cache.objectForKey(key as! AnyObject) as? U
  }

  public func setObject(obj: U, forKey key: T) {
    cache.setObject(obj as! AnyObject, forKey: key as! AnyObject)
  }
  
  public func setObject(obj: U, forKey key: T, cost g: Int) {
    cache.setObject(obj as! AnyObject, forKey: key as! AnyObject, cost: g)
  }
  
  public func removeObjectForKey(key: T) {
    cache.removeObjectForKey(key as! AnyObject)
  }
  
  public func removeAllObjects() {
   cache.removeAllObjects()
  }
  
  // MARK: Subscribt Functionality
  
  public subscript(key: T) -> U? {
    get {
      return objectForKey(key)
    }
    set(newValue) {
      if let newValue = newValue {
        setObject(newValue, forKey: key)
      }
    }
  }
  
}