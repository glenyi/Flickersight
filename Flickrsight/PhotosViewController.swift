//
//  PhotosViewController.swift
//  Flickrsight
//
//  Created by Glen Yi on 2015-11-07.
//  Copyright © 2015 On The Pursuit Inc. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    let PhotoCellIdentifier = "PhotoCell"
    
    let PhotosHorizontalInset: CGFloat = 40.0
    let PhotosVerticalInset: CGFloat = 20.0
    
    let PhotoTappedFrameSizeRatio: CGFloat = 0.95
    let PhotoTappedAnimationDuration: NSTimeInterval = 0.5
    let PhotoTappedAnimationOptions: UIViewAnimationOptions = [ .CurveEaseInOut ]
    let PhotoTappedSpringDampening: CGFloat = 0.9
    
    let PhotosDefaultSearchText = "cat"
    let PhotosCount = 10

    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var activityView: UIActivityIndicatorView!
    
    var photos: [FlickrPhoto] = []
    var lastSearchText: String = ""
    
    var effectView: UIVisualEffectView?
    var photoImageView: UIImageView?
    var selectedPhotoCell: PhotoCollectionViewCell?
    
    
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
    
    func userClickedPhotoCell(cell: PhotoCollectionViewCell) {
        // Init photo image view
        let superview = self.navigationController!.view
        let frame = superview.convertRect(cell.frame, fromView: self.collectionView)
        let photoImageView = UIImageView(frame: frame)
        photoImageView.image = cell.photoImageView.image
        photoImageView.userInteractionEnabled = true
        photoImageView.contentMode = cell.photoImageView.contentMode
        photoImageView.layer.masksToBounds = true
        
        // Add blur effect and image view
        let blurEffect = UIBlurEffect(style: .Light)
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.frame = superview.bounds
        effectView.alpha = 0
        superview.addSubview(effectView)
        superview.addSubview(photoImageView)
        cell.hidden = true
        
        // Add tap gesture to dismiss view
        let tapGesture = UITapGestureRecognizer(target: self, action: "photoImageViewTapped:")
        superview.addGestureRecognizer(tapGesture)
        
        // Calculate new image view frame
        let width = PhotoTappedFrameSizeRatio * superview.frame.width
        let height = photoImageView.frame.height * width / photoImageView.frame.width
        let size = CGSize(width: width, height: height)
        let origin = CGPoint(x: (superview.frame.width - width)/2.0, y: (superview.frame.height - height)/2.0)
        let rect = CGRect(origin: origin, size: size)
        
        // Animate photo image view
        UIView.animateWithDuration(PhotoTappedAnimationDuration, delay: 0, usingSpringWithDamping: PhotoTappedSpringDampening, initialSpringVelocity: 0, options: PhotoTappedAnimationOptions, animations: { () -> Void in
            UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Slide)
            self.navigationController!.navigationBarHidden = true
            photoImageView.frame = rect
            effectView.alpha = 1.0
        }, completion: { (completed) -> Void in
            self.effectView = effectView
            self.photoImageView = photoImageView
            self.selectedPhotoCell = cell
        })
    }
    
    func photoImageViewTapped(tapGesture: UITapGestureRecognizer) {
        guard let effectView = self.effectView, let photoImageView = self.photoImageView, let cell = self.selectedPhotoCell, let superview = tapGesture.view else {
            return
        }
        
        // Animate photo image view
        UIView.animateWithDuration(PhotoTappedAnimationDuration, delay: 0, usingSpringWithDamping: PhotoTappedSpringDampening, initialSpringVelocity: 0, options: PhotoTappedAnimationOptions, animations: { () -> Void in
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)
            self.navigationController!.navigationBarHidden = false
            photoImageView.frame = self.navigationController!.view.convertRect(cell.frame, fromView: self.collectionView)
            self.effectView!.alpha = 0.0
        }, completion: { (completed) -> Void in
            superview.removeGestureRecognizer(tapGesture)
            photoImageView.removeFromSuperview()
            effectView.removeFromSuperview()
            cell.hidden = false
            
            self.effectView = nil
            self.photoImageView = nil
            self.selectedPhotoCell = nil
        })
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
        
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? PhotoCollectionViewCell, let _ = cell.photoImageView.image {
            self.userClickedPhotoCell(cell)
        }
    }
    
}

