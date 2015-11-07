//
//  FlickrPhoto.swift
//  Flickrsight
//
//  Created by Glen Yi on 2015-11-07.
//  Copyright © 2015 On The Pursuit Inc. All rights reserved.
//

import UIKit

class FlickrPhoto: NSObject {
    
    // https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}_[mstzb].jpg
    // https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}.jpg
    let FlickrImageURLFormat = "https://farm%i.staticflickr.com/%@/%@_%@.jpg"
    let FlickrImageURLSizeSuffix = "z"
    
    var id: String = ""
    var owner: String = ""
    var secret: String = ""
    var server: String = ""
    var farm: Int = 0
    
    var title: String = ""
    var image: UIImage?
    
    var imageURL: NSURL? {
        get {
            guard self.id.characters.count > 0 else {
                return nil
            }
            
            // Form image URL
            let urlString = String(format: FlickrImageURLFormat, self.farm, self.server, self.id, self.secret, FlickrImageURLSizeSuffix)
            
            return NSURL(string: urlString)
        }
    }
    
    func loadImage(completion: (image: UIImage?) -> Void) {
        guard let imageURL = self.imageURL else {
            completion(image: nil)
            return
        }
        
        // Load image asynchronously if needed
        if let image = self.image {
            completion(image: image)
        } else {
            NSURLSession.sharedSession().dataTaskWithURL(imageURL, completionHandler: { (data, response, error) -> Void in
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    guard let data = data where error == nil, let image = UIImage(data: data) else {
                        completion(image: nil)
                        return
                    }
                    
                    self.image = image
                    completion(image: image)
                }
            }).resume()
        }
    }
    
    func loadFromFlickrAPI(dictionary: [String:AnyObject]?) {
        guard let dictionary = dictionary else {
            return
        }
        
        self.id = dictionary["id"] as! String
        self.owner = dictionary["owner"] as! String
        self.secret = dictionary["secret"] as! String
        self.server = dictionary["server"] as! String
        self.farm = dictionary["farm"] as! Int
        self.title = dictionary["title"] as! String
    }
    
}
