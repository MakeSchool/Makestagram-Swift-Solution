//
//  TimelineViewController.swift
//  Makestagram
//
//  Created by Benjamin Encz on 5/21/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit

class TimelineViewController: UIViewController {

  var photoTakingHelper: PhotoTakingHelper?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.tabBarController?.delegate = self
  }
  
  // MARK: View callbacks
  
  func takePhoto() {
    // instantiate photo taking class, provide callback for when photo is selected
    photoTakingHelper = PhotoTakingHelper(viewController: self.tabBarController!, callback: { (image: UIImage?) in
      // don't do anything, yet...
    })
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