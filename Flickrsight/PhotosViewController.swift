//
//  PhotosViewController.swift
//  Flickrsight
//
//  Created by Glen Yi on 2015-11-07.
//  Copyright © 2015 On The Pursuit Inc. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, UINavigationControllerDelegate {
    
    let PhotoSegueIdentifier = "PhotoSegue"
    
    let PhotoCellIdentifier = "PhotoCell"
    let PhotosVerticalInset: CGFloat = 20.0
    
    let PhotosDefaultSearchText = "cat"
    let PhotosCount = 20

    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var activityView: UIActivityIndicatorView!
    
    var photos: [FlickrPhoto] = []
    var lastSearchText: String = ""
    var sortParam: FlickrAPISortParam = .DatePostedAsc
    
    let sortAlertController: UIAlertController = {
        let alertController = UIAlertController(title: "Sort Photos", message: nil, preferredStyle: .ActionSheet)
        
        return alertController
    }()
    
    lazy var animationController: PhotoAnimationController = {
        let animationController = PhotoAnimationController()
        
        return animationController
    }()
    
    var selectedPhotoCell: PhotoCollectionViewCell?
    var selectedPhoto: FlickrPhoto?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Init sort alert controller
        self.sortAlertController.addAction(UIAlertAction(title: "Date Posted ▲", style: .Default, handler: { (action) -> Void in
            self.loadPhotosWithSearchText(self.lastSearchText, count: self.PhotosCount, sortParam: .DatePostedAsc)
        }))
        self.sortAlertController.addAction(UIAlertAction(title: "Date Posted ▼", style: .Default, handler: { (action) -> Void in
            self.loadPhotosWithSearchText(self.lastSearchText, count: self.PhotosCount, sortParam: .DatePostedDesc)
        }))
        self.sortAlertController.addAction(UIAlertAction(title: "Date Taken ▲", style: .Default, handler: { (action) -> Void in
            self.loadPhotosWithSearchText(self.lastSearchText, count: self.PhotosCount, sortParam: .DateTakenAsc)
        }))
        self.sortAlertController.addAction(UIAlertAction(title: "Date Taken ▼", style: .Default, handler: { (action) -> Void in
            self.loadPhotosWithSearchText(self.lastSearchText, count: self.PhotosCount, sortParam: .DateTakenDesc)
        }))
        self.sortAlertController.addAction(UIAlertAction(title: "Interestingness ▲", style: .Default, handler: { (action) -> Void in
            self.loadPhotosWithSearchText(self.lastSearchText, count: self.PhotosCount, sortParam: .InterestingnessAsc)
        }))
        self.sortAlertController.addAction(UIAlertAction(title: "Interestingness ▼", style: .Default, handler: { (action) -> Void in
            self.loadPhotosWithSearchText(self.lastSearchText, count: self.PhotosCount, sortParam: .InterestingnessDesc)
        }))
        self.sortAlertController.addAction(UIAlertAction(title: "Relevance", style: .Default, handler: { (action) -> Void in
            self.loadPhotosWithSearchText(self.lastSearchText, count: self.PhotosCount, sortParam: .Relevance)
        }))
        self.sortAlertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in
        }))
        
        // Init search controller
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        searchBar.text = PhotosDefaultSearchText
        searchBar.showsCancelButton = true
        searchBar.delegate = self
        
        // Init nav controller
        self.navigationController!.delegate = self
        self.navigationItem.titleView = searchBar
        
        // Set collection view layout
        let layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let width = self.view.frame.width/2.5
        layout.itemSize = CGSize(width: width, height: width)
        let horizontalInset = (self.view.frame.width - 2 * width) / 3.0
        layout.sectionInset = UIEdgeInsets(top: PhotosVerticalInset, left: horizontalInset, bottom: PhotosVerticalInset, right: horizontalInset)
        
        self.loadPhotosWithSearchText(PhotosDefaultSearchText, count: PhotosCount, sortParam: self.sortParam)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: Action outlets
    
    @IBAction func sortClicked(sender: UIBarButtonItem) {
        self.navigationController!.view.endEditing(true)
        self.presentViewController(self.sortAlertController, animated: true) { () -> Void in
        }
    }
    
    
    // MARK: PhotosViewController methods
    
    func loadPhotosWithSearchText(text: String, count: Int, sortParam: FlickrAPISortParam) {
        self.lastSearchText = text
        
        self.activityView.startAnimating()
        self.photos.removeAll()
        self.collectionView.reloadData()
        FlickrAPIManager.sharedManager.getPhotos(text, count: count, sortParam: sortParam) { (photos, error) -> Void in
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
        
        self.loadPhotosWithSearchText(text, count: PhotosCount, sortParam: self.sortParam)
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
        cell.loadFlickrPhoto(photo)
        
        return cell
    }
    
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard indexPath.row < self.photos.count else {
            return
        }
        
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? PhotoCollectionViewCell, let _ = cell.photoImageView.image {
            self.navigationController!.view.endEditing(true)
            
            self.selectedPhotoCell = cell
            self.selectedPhoto = self.photos[indexPath.row]
            self.performSegueWithIdentifier(PhotoSegueIdentifier, sender: self)
        }
    }
    
    
    // MARK: UINavigationControllerDelegate
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.animationController.operation = operation
        self.animationController.cell = self.selectedPhotoCell
        
        return self.animationController
    }


    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == PhotoSegueIdentifier {
            let vc = segue.destinationViewController as! PhotoDetailsViewController
            vc.photo = self.selectedPhoto
        }
    }
    
}

