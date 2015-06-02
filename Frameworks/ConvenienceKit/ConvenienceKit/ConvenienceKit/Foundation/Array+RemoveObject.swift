//
//  Array+RemoveObject.swift
//  ConvenienceKit
//
//  Created by Benjamin Encz on 4/17/15.
//  Copyright (c) 2015 Benjamin Encz. All rights reserved.
//

import Foundation

// Thanks to Janos: http://stackoverflow.com/questions/24938948/array-extension-to-remove-object-by-value
public func removeObject<T : Equatable>(object: T, inout fromArray array: [T])
{
  var index = find(array, object)
  if let index = index {
    array.removeAtIndex(index)
  }
}