//
//  PresentViewControllerAnywhere.swift
//  ConvenienceKit
//
//  Created by Benjamin Encz on 4/10/15.
//  Copyright (c) 2015 Benjamin Encz. All rights reserved.
//

import Foundation
import UIKit
import Quick
import Nimble
import ConvenienceKit

class PresentViewControllerAnywhereSpec : QuickSpec {
  override func spec() {
    
    describe("UIViewController PresentAnywhere Extension") {

      context("when used on a plain view controller") {
        
        it("presents the controller on the plain view controller") {
          let uiApplication = UIApplication.sharedApplication()
          var window = UIApplication.sharedApplication().windows[0] as! UIWindow
          let presentedViewController = UIViewController()
          
          window.rootViewController = UIViewController()
          let rootViewController = window.rootViewController!
          rootViewController.presentViewControllerFromTopViewController(presentedViewController)
          
          expect(presentedViewController.presentingViewController).to(equal(rootViewController))
        }
        
      }
      
//      context("when used on a navigation view controller") {
//        
//        it("presents it on the first content view controller when only one is added") {
//          let uiApplication = UIApplication.sharedApplication()
//          let window = UIApplication.sharedApplication().windows[0] as! UIWindow
//          let firstContentViewController = UIViewController()
//          let secondContentViewController = UIViewController()
//          let navigationController = UINavigationController(rootViewController: firstContentViewController)
//          navigationController.pushViewController(secondContentViewController, animated: false)
//          window.rootViewController = navigationController
//          
//          window.addSubview(navigationController.view)
//          
//          let presentedViewController = UIViewController()
//          let rootViewController = window.rootViewController!
//          rootViewController.presentViewControllerFromTopViewController(presentedViewController)
//
////          expect(presentedViewController.presentingViewController).to(equal(secondContentViewController))
//        }
//      }
      
//      context("when used on a modally presented view controller") {
//
//        it("presents it on the modal view controller") {
//          let uiApplication = UIApplication.sharedApplication()
//          var window = UIApplication.sharedApplication().windows[0] as! UIWindow
//          window.rootViewController = UIViewController()
//          
//          let modalViewController = UIViewController()
//          let presentedViewController = UIViewController()
//          
//          window.rootViewController?.presentViewController(modalViewController, animated: false, completion: nil)
//          
//          window.rootViewController?.presentViewControllerFromTopViewController(presentedViewController)
//          
//          expect(presentedViewController.presentingViewController).to(equal(modalViewController))
//        }
//        
//      }
    }
    
  }
}