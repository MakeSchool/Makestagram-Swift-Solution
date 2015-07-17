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
  
  /** View controller on which View Controllers should be presented */
  weak var viewController: UIViewController!
  var successCallback: PhotoTakingHelperCallback
  var imagePickerController: UIImagePickerController?
  
  var presentedViewControllerStack: [UIViewController] = []
  
  init(viewController: UIViewController, successCallback: PhotoTakingHelperCallback) {
    self.viewController = viewController
    self.successCallback = successCallback
    
    super.init()
    
    showPhotoSourceSelection()
    presentedViewControllerStack.append(viewController)
  }
  
  func pushModalViewController(newViewController: UIViewController) {
    presentedViewControllerStack.last?.presentViewController(newViewController, animated: true, completion: nil)
    presentedViewControllerStack.append(newViewController)
  }
  
  func popModalViewController() {
    presentedViewControllerStack.last?.dismissViewControllerAnimated(true, completion: nil)
    presentedViewControllerStack.removeLast()
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
    pushModalViewController(imagePickerController!)
    imagePickerController!.delegate = self
  }
  
}

extension PhotoTakingHelper: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
    let filterViewController = FilterViewController(image: image)
    filterViewController.delegate = self
    pushModalViewController(filterViewController)
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    popModalViewController()
  }
  
}

extension PhotoTakingHelper: FilterViewControllerDelegate {
  
  func filterViewController(controller: FilterViewController, selectedImage: UIImage) {
    successCallback(selectedImage)
    // pop all view controllers
    viewController.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func filterViewControllerCancelled(controller: FilterViewController) {
    popModalViewController()
  }
  
}