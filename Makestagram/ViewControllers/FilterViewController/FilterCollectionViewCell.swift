//
//  FilterCollectionViewCell.swift
//  Makestagram
//
//  Created by Benjamin Encz on 4/9/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit

class FilterCollectionViewCell: UICollectionViewCell {
  
  @IBOutlet weak var filterLabel: UILabel!
  @IBOutlet weak var filterPreviewImage: UIImageView!

  var filter: Filter? {
    didSet {
      if let filter = filter {
        filterLabel.text = filter.filterName
        filterPreviewImage.image = UIImage(named: filter.filterPreviewImageFile)
      }
    }
  }
  
}