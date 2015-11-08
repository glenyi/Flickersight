//
//  FlickrAPIManager.swift
//  Flickrsight
//
//  Created by Glen Yi on 2015-11-07.
//  Copyright © 2015 On The Pursuit Inc. All rights reserved.
//

import UIKit


class FlickrAPIManager: NSObject {

    let FlickrAPIFormat = "json"
    let FlickrAPITimeoutInterval: NSTimeInterval = 10
    
    static let sharedManager = FlickrAPIManager()
    
    func urlRequestWithParams(params: [String:AnyObject], method: String) -> NSMutableURLRequest? {
        // Create query items from params
        let urlComponents = NSURLComponents(string: FlickrAPIBaseURL)!
        var queryItems = [ NSURLQueryItem(name: FlickrAPIParamApiKey, value: FlickrAPIKey),
            NSURLQueryItem(name: FlickrAPIParamFormat, value: FlickrAPIFormat),
            NSURLQueryItem(name: FlickrAPIParamNoCallback, value: String(1))]
        for (key, value) in params {
            queryItems.append( NSURLQueryItem(name: key, value: String(value)) )
        }
        urlComponents.queryItems = queryItems
        
        // Create URL request
        guard let url = urlComponents.URL else {
            return nil
        }
        let request = NSMutableURLRequest(URL: url, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: FlickrAPITimeoutInterval)
        request.HTTPMethod = method
        
        return request
    }

    func getPhotos(searchText: String, count: Int, completed: (photos: [FlickrPhoto], error: NSError?) -> Void) -> NSURLSessionTask? {
        // Create request params
        let params: [String:AnyObject] = [ FlickrAPIParamMethod:FlickrAPIMethodSearch,
            FlickrAPIParamTags:searchText,
            FlickrAPIParamPerPage:count ]
        
        // Start URL session task
        guard let request = self.urlRequestWithParams(params, method: HTTPMethodGet) else {
            return nil
        }
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            // Check for error or no data
            guard error == nil else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completed(photos: [], error: error)
                })
                return
            }
            guard let data = data else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completed(photos: [], error: NSError(domain: "Flickrswift", code: 1, userInfo: nil))
                })
                return
            }
            
            do {
                // Attempt to parse json data
                let responseObject = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                let json = (responseObject[FlickrAPIDataKeyPhotos] as! [String:AnyObject])[FlickrAPIDataKeyPhoto]  as? [ [String:AnyObject] ]
                guard let photosJson = json else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completed(photos: [], error: NSError(domain: "Flickrswift", code: 1, userInfo: nil))
                    })
                    return
                }
                
                // Convert json to FlickrPhoto objects
                var photos: [FlickrPhoto] = []
                for photoJson in photosJson {
                    let photo = FlickrPhoto()
                    photo.loadFromFlickrAPI(photoJson)
                    photos.append(photo)
                }
                
                // Return on main thread
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completed(photos: photos, error: nil)
                })
            } catch let error as NSError {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completed(photos: [], error: error)
                })
            }
        }
        task.resume()
        
        return task
    }
    
}
