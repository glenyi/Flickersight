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
    let FlickrImageURLFormat = "https://farm%i.staticflickr.com/%@/%@_%@_%@.jpg"
    let FlickrImageURLSizeSuffix = "m"
    
    var id: String = ""
    var owner: String = ""
    var secret: String = ""
    var server: String = ""
    var farm: Int = 0
    
    var title: String = ""
    
    var imageURL: NSURL? {
        get {
            guard self.id.characters.count > 0 else {
                return nil
            }
            
            let url = NSURL()
            
            // TODO: Fill out url
            return url
        }
    }
    
    func loadFromFlickrAPI(dictionary: Dictionary<String, AnyObject>) {
        
    }
    
}
