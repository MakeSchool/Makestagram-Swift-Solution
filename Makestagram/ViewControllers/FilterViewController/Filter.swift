//
//  Filter.swift
//  Makestagram
//
//  Created by Benjamin Encz on 4/9/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit

struct Filter {
  let filterName: String
  let filterFunction: UIImage -> UIImage
  let filterPreviewImageFile: String
}

let context = CIContext(options:nil)

// MARK: Filters

func applyFilter(filter: CIFilter, toImage image: UIImage) -> UIImage {
  let originalOrientation = image.imageOrientation;
  let originalScale = image.scale
  
  let cgimg = context.createCGImage(filter.outputImage, fromRect: filter.outputImage.extent())
  
  return UIImage(CGImage: cgimg, scale: originalScale, orientation: originalOrientation)!
}

func sepiaFilter(image: UIImage) -> UIImage {
  let beginImage = CIImage(image: image)
  let filter = CIFilter(name: "CISepiaTone")
  filter.setValue(beginImage, forKey: kCIInputImageKey)
  filter.setValue(0.5, forKey: kCIInputIntensityKey)
  
  return applyFilter(filter, toImage:image)
}

func vignetteFilter(image: UIImage) -> UIImage {
  let beginImage = CIImage(image: image)
  let parameters = [ kCIInputRadiusKey: 0.7, kCIInputIntensityKey: 20, kCIInputImageKey: beginImage ]
  let filter = CIFilter(name: "CIVignette", withInputParameters: parameters)
  
  return applyFilter(filter, toImage:image)
}

func vibranceFilter(image: UIImage) -> UIImage {
  let beginImage = CIImage(image: image)
  
  let parameters = [kCIInputImageKey: beginImage, "inputAmount": 3]
  let filter = CIFilter(name: "CIVibrance", withInputParameters: parameters)
    
  return applyFilter(filter, toImage:image)
}

func noFilter(image: UIImage) -> UIImage {
  return image
}

struct Filters {
  static let NoFilter = Filter(filterName: "None", filterFunction: noFilter, filterPreviewImageFile: "filter_normal.png")
  static let SepiaFilter = Filter(filterName: "Sepia", filterFunction: sepiaFilter, filterPreviewImageFile: "filter_sepia.png")
  static let VignetteFilter = Filter(filterName: "Vignette",  filterFunction: vignetteFilter, filterPreviewImageFile: "filter_vignette.png")
  static let VibranceFilter = Filter(filterName: "Vibrance",  filterFunction: vibranceFilter, filterPreviewImageFile: "filter_vibrant.png")
}