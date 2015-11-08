//
//  PhotoAnimationController.swift
//  Flickrsight
//
//  Created by Glen Yi on 2015-11-07.
//  Copyright © 2015 On The Pursuit Inc. All rights reserved.
//

import UIKit

class PhotoAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    let NavigationBarAnimationDuration: NSTimeInterval = 0.3
    
    let PhotoAnimationDuration: NSTimeInterval = 0.5
    let PhotoAnimationOptions: UIViewAnimationOptions = [ .CurveEaseInOut ]
    let PhotoSpringDampening: CGFloat = 0.8
    
    let effectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .Dark)
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.alpha = 0
        
        return effectView
    }()
    
    let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        
        return imageView
    }()
    
    
    var operation: UINavigationControllerOperation = .Push
    var cell: PhotoCollectionViewCell?
    var snapshotView: UIView!
    
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return PhotoAnimationDuration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let cell = self.cell else {
            transitionContext.completeTransition(false)
            return
        }
        
        let containerView = transitionContext.containerView()!
        
        if operation == .Push {
            let photosVc = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! PhotosViewController
            let detailsVc = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! PhotoDetailsViewController
            
            // Init container view
            cell.hidden = true
            detailsVc.photoImageView.hidden = true
            detailsVc.view.backgroundColor = UIColor.clearColor()
            containerView.addSubview(photosVc.view)
            containerView.addSubview(detailsVc.view)
            containerView.layoutIfNeeded()
            
            // Init photo image view
            let cellFrame = containerView.convertRect(cell.frame, fromView: photosVc.collectionView)
            self.photoImageView.frame = cellFrame
            self.photoImageView.image = cell.photoImageView.image
            self.photoImageView.contentMode = cell.photoImageView.contentMode
            
            // Init blur effect view
            self.effectView.frame = containerView.bounds
            self.effectView.alpha = 0
            
            // Add subviews
            detailsVc.view.insertSubview(self.effectView, belowSubview: detailsVc.photoImageView)
            detailsVc.view.insertSubview(self.photoImageView, belowSubview: detailsVc.photoImageView)
            
            // Animate status bar and navigation bar
            UIView.animateWithDuration(NavigationBarAnimationDuration, animations: { () -> Void in
                UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
                photosVc.navigationController!.navigationBar.alpha = 0
            })
            
            // Animate photo image view
            let frame = detailsVc.photoImageView.frame
            UIView.animateWithDuration(PhotoAnimationDuration, delay: 0, usingSpringWithDamping: PhotoSpringDampening, initialSpringVelocity: 0, options: PhotoAnimationOptions, animations: { () -> Void in
                self.photoImageView.frame = frame
                self.effectView.alpha = 1.0
            }, completion: { (completed) -> Void in
                // Add snapshot view
                self.snapshotView = photosVc.view.snapshotViewAfterScreenUpdates(false)
                detailsVc.view.insertSubview(self.snapshotView, belowSubview: self.effectView)
                
                // Finalize views
                detailsVc.photoImageView.hidden = false
                self.photoImageView.removeFromSuperview()
                photosVc.view.removeFromSuperview()
                
                transitionContext.completeTransition(true)
            })
        } else if operation == .Pop {
            let detailsVc = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! PhotoDetailsViewController
            let photosVc = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! PhotosViewController
            
            // Init container view
            containerView.insertSubview(photosVc.view, belowSubview: detailsVc.view)
            
            // Init photo image views
            detailsVc.photoImageView.hidden = true
            self.photoImageView.frame = detailsVc.photoImageView.frame
            containerView.addSubview(self.photoImageView)
            
            // Animate status bar and navigation bar
            UIView.animateWithDuration(NavigationBarAnimationDuration, animations: { () -> Void in
                UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
                photosVc.navigationController!.navigationBar.alpha = 1.0
            })
            
            // Animate photo image view
            let frame = containerView.convertRect(cell.frame, fromView: photosVc.collectionView)
            UIView.animateWithDuration(PhotoAnimationDuration, delay: 0, usingSpringWithDamping: PhotoSpringDampening, initialSpringVelocity: 0, options: PhotoAnimationOptions, animations: { () -> Void in
                self.photoImageView.frame = frame
                detailsVc.view.alpha = 0
            }, completion: { (completed) -> Void in
                // Finalize views
                detailsVc.view.removeFromSuperview()
                self.snapshotView.removeFromSuperview()
                self.photoImageView.removeFromSuperview()
                self.effectView.removeFromSuperview()
                cell.hidden = false
                
                transitionContext.completeTransition(true)
            })
        }
    }
}
