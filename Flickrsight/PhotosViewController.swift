//
//  PhotosViewController.swift
//  Flickrsight
//
//  Created by Glen Yi on 2015-11-07.
//  Copyright © 2015 On The Pursuit Inc. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {

    let PhotoDetailSegueIdentifier = "PhotoSegue"
    let PhotoCellIdentifier = "PhotoCell"
    
    let PhotosHorizontalInset: CGFloat = 40.0
    let PhotosVerticalInset: CGFloat = 20.0
    
    let PhotosDefaultSearchText = "cat"
    let PhotosCount = 20
    
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var activityView: UIActivityIndicatorView!
    
    var photos: [FlickrPhoto] = []
    var photo: FlickrPhoto?
    var lastSearchText: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Init search controller
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        searchBar.text = PhotosDefaultSearchText
        searchBar.showsCancelButton = true
        searchBar.delegate = self
        // Add search bar to navigation bar
        self.navigationItem.titleView = searchBar
        
        // Set collection view layout
        let layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: PhotosVerticalInset, left: PhotosHorizontalInset, bottom: PhotosVerticalInset, right: PhotosHorizontalInset)
        
        self.loadPhotosWithSearchText(PhotosDefaultSearchText, count: PhotosCount)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: PhotosViewController methods
    
    func loadPhotosWithSearchText(text: String, count: Int) {
        self.lastSearchText = text
        
        self.activityView.startAnimating()
        self.photos.removeAll()
        self.collectionView.reloadData()
        FlickrAPIManager.sharedManager.getPhotos(text, count: count) { (photos, error) -> Void in
            self.activityView.stopAnimating()
            if let error = error {
                print(error)
            } else {
                self.photos.appendContentsOf(photos)
                self.collectionView.reloadData()
            }
        }
    }
    
    
    // MARK: UISearchBarDelegate
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = self.lastSearchText
        
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        guard let text = searchBar.text else {
            searchBar.resignFirstResponder()
            return
        }
        
        self.loadPhotosWithSearchText(text, count: PhotosCount)
        searchBar.resignFirstResponder()
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
        if let imageURL = photo.imageURL {
            print(imageURL)
        }
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

