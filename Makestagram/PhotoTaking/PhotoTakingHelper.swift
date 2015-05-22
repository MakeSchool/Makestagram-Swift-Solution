//
//  PhotoTakingHelper.swift
//  Makestagram
//
//  Created by Benjamin Encz on 5/21/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit

typealias PhotoTakingHelperCallback = UIImage? -> Void

class PhotoTakingHelper : NSObject {
  
  /** View controller on which AlertViewController and UIImagePickerController are presented */
  weak var viewController: UIViewController!
  var callback: PhotoTakingHelperCallback
  var imagePickerController: UIImagePickerController?
  
  init(viewController: UIViewController, callback: PhotoTakingHelperCallback) {
    self.viewController = viewController
    self.callback = callback
    
    super.init()
    
    showPhotoSourceSelection()
  }
  
  func showPhotoSourceSelection() {
    // Allow user to choose between photo library and camera
    let alertController = UIAlertController(title: nil, message: "Where do you want to get your picture from?", preferredStyle: .ActionSheet)
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
    alertController.addAction(cancelAction)
    
    // Only show camera option if rear camera is available
    if (UIImagePickerController.isCameraDeviceAvailable(.Rear)) {
      let cameraAction = UIAlertAction(title: "Photo from Camera", style: .Default) { (action) in
        self.showImagePickerController(.Camera)
      }
      
      alertController.addAction(cameraAction)
    }
    
    let photoLibraryAction = UIAlertAction(title: "Photo from Library", style: .Default) { (action) in
      self.showImagePickerController(.PhotoLibrary)
    }
    
    alertController.addAction(photoLibraryAction)
    
    viewController.presentViewController(alertController, animated: true, completion: nil)
  }
  
  func showImagePickerController(sourceType: UIImagePickerControllerSourceType) {
    imagePickerController = UIImagePickerController()
    imagePickerController!.sourceType = sourceType
    self.viewController.presentViewController(imagePickerController!, animated: true, completion: nil)
  }
  
}