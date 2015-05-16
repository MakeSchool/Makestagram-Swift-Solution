//
//  Delay.swift
//  ConvenienceKit
//
//  Created by Benjamin Encz on 4/13/15.
//  Copyright (c) 2015 Benjamin Encz. All rights reserved.
//

import Foundation


// Thanks to matt on StackOverflow: http://stackoverflow.com/questions/24034544/dispatch-after-gcd-in-swift
public func delay(delay:Double, closure:()->()) {
  dispatch_after(
    dispatch_time(
      DISPATCH_TIME_NOW,
      Int64(delay * Double(NSEC_PER_SEC))
    ),
    dispatch_get_main_queue(), closure)
}