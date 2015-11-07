//
//  PhotoDetailViewController.swift
//  Flickrsight
//
//  Created by Glen Yi on 2015-11-07.
//  Copyright © 2015 On The Pursuit Inc. All rights reserved.
//

import UIKit

class PhotoDetailViewController: UIViewController {

    @IBOutlet var photoImageView: UIImageView!
    
    var photo: FlickrPhoto?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard let photo = self.photo else {
            return
        }
        
        if let image = photo.image {
            self.photoImageView.image = image
        } else {
            self.photoImageView.image = nil
            photo.loadImage { (image) -> Void in
                guard let image = image else {
                    return
                }
                
                self.photoImageView.image = image
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func closeClicked(sender: UIButton) {
        self.dismissViewControllerAnimated(true) { () -> Void in
        }
    }

}
