//
//  PhotoDetailsViewController.swift
//  Flickrsight
//
//  Created by Glen Yi on 2015-11-07.
//  Copyright © 2015 On The Pursuit Inc. All rights reserved.
//

import UIKit

class PhotoDetailsViewController: UIViewController {

    @IBOutlet var photoImageView: UIImageView!
    
    var photo: FlickrPhoto?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        // Load photo
        if let photo = self.photo {
            if let image = photo.image {
                self.photoImageView.image = image
            } else {
                photo.loadImage({ (image) -> Void in
                    self.photoImageView.image = image
                })
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Action outlets
    
    @IBAction func viewTapped(sender: UITapGestureRecognizer) {
        self.navigationController!.popViewControllerAnimated(true)
    }
    
}
