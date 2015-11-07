//
//  PhotoCollectionViewCell.swift
//  Flickrsight
//
//  Created by Glen Yi on 2015-11-07.
//  Copyright © 2015 On The Pursuit Inc. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var activityView: UIActivityIndicatorView!
    
    func loadFlickrPhoto(photo: FlickrPhoto?) {
        guard let photo = photo else {
            self.photoImageView = nil
            return
        }
        
        if let image = photo.image {
            self.photoImageView.image = image
        } else {
            self.photoImageView.image = nil
            self.activityView.startAnimating()
            photo.loadImage { (image) -> Void in
                self.activityView.stopAnimating()
                guard let image = image else {
                    return
                }
                
                self.photoImageView.image = image
            }
        }
    }
}
