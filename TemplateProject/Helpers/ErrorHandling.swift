//
//  ErrorHandling.swift
//  Template Project
//
//  Created by Benjamin Encz on 4/10/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import ConvenienceKit

/**
  This struct provides basic Error handling functionality.
*/
struct ErrorHandling {
  
  static let ErrorTitle           = "Error"
  static let ErrorOKButtonTitle   = "Ok"
  static let ErrorDefaultMessage  = "Something unexpected happened, sorry for that!"
  
  /** 
    This default error handler presents an Alert View on the topmost View Controller 
  */
  static func defaultErrorHandler(error: NSError) {
    var alert = UIAlertController(title: ErrorTitle, message: ErrorDefaultMessage, preferredStyle: UIAlertControllerStyle.Alert)
    alert.addAction(UIAlertAction(title: ErrorOKButtonTitle, style: UIAlertActionStyle.Default, handler: nil))
    
    let window = UIApplication.sharedApplication().windows[0] as! UIWindow
    window.rootViewController?.presentViewControllerFromTopViewController(alert, animated: true, completion: nil)
  }
  
  /** 
    A PFBooleanResult callback block that only handles error cases. You can pass this to completion blocks of Parse Requests 
  */
  static func errorHandlingCallback(success: Bool, error: NSError?) -> Void {
    if let error = error {
      ErrorHandling.defaultErrorHandler(error)
    }
  }
  
}