//
//  PhotoCollectionViewCell.swift
//  Flickrsight
//
//  Created by Glen Yi on 2015-11-07.
//  Copyright © 2015 On The Pursuit Inc. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    let PhotoFadeAnimationDuration: NSTimeInterval = 0.3
    
    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var activityView: UIActivityIndicatorView!
    
    private var imageTask: NSURLSessionTask?
    
    func loadFlickrPhoto(photo: FlickrPhoto?) {
        guard let photo = photo else {
            self.photoImageView.image = nil
            self.activityView.stopAnimating()
            return
        }
        
        // Cancel previous image loading tasks
        self.imageTask?.cancel()
        self.imageTask = nil
        
        // Load cached image or from URL
        if let image = photo.image {
            self.photoImageView.image = image
            self.photoImageView.alpha = 1.0
            self.activityView.stopAnimating()
        } else {
            self.photoImageView.image = nil
            self.photoImageView.alpha = 0.0
            self.activityView.startAnimating()
            self.imageTask = photo.loadImage { (image) -> Void in
                self.activityView.stopAnimating()
                guard let image = image else {
                    return
                }
                
                // Fade in image
                self.photoImageView.image = image
                UIView.animateKeyframesWithDuration(self.PhotoFadeAnimationDuration, delay: 0, options: [], animations: { () -> Void in
                    self.photoImageView.alpha = 1.0
                }, completion: { (completed) -> Void in
                })
            }
        }
    }
}
