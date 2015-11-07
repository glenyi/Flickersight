//
//  PhotosViewController.swift
//  Flickrsight
//
//  Created by Glen Yi on 2015-11-07.
//  Copyright © 2015 On The Pursuit Inc. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    let PhotoDetailSegueIdentifier = "PhotoSegue"
    let PhotoCellIdentifier = "PhotoCell"
    
    let PhotosHorizontalInset: CGFloat = 40.0
    let PhotosVerticalInset: CGFloat = 20.0
    
    @IBOutlet var collectionView: UICollectionView!
    
    var photos: [FlickrPhoto] = []
    var photo: FlickrPhoto?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set collection view layout
        let layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: PhotosVerticalInset, left: PhotosHorizontalInset, bottom: PhotosVerticalInset, right: PhotosHorizontalInset)
        
        self.loadPhotosWithSearchText("cat", count: 10)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: PhotosViewController methods
    
    func loadPhotosWithSearchText(text: String, count: Int) {
        FlickrAPIManager.sharedManager.getPhotos(text, count: count) { (photos, error) -> Void in
            if error != nil {
                print(error!)
            } else {
                print(photos)
                self.photos = photos
                self.collectionView.reloadData()
            }
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PhotoCellIdentifier, forIndexPath: indexPath) as! PhotoCollectionViewCell
        
        guard indexPath.row < self.photos.count else {
            cell.loadFlickrPhoto(nil)
            
            return cell
        }
        
        let photo = self.photos[indexPath.row]
        print(photo.imageURL)
        cell.loadFlickrPhoto(photo)
        
        return cell
    }
    
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard indexPath.row < self.photos.count else {
            return
        }
        self.photo = self.photos[indexPath.row]
        self.performSegueWithIdentifier(PhotoDetailSegueIdentifier, sender: self)
    }
    
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == PhotoDetailSegueIdentifier {
            let vc = segue.destinationViewController as! PhotoDetailViewController
            vc.photo = self.photo
        }
    }

}

