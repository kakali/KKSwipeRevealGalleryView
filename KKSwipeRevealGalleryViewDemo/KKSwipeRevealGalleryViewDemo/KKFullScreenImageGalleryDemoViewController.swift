//
//  KKFullScreenImageGalleryDemoViewController.swift
//  KKSwipeRevealGalleryViewDemo
//
//  Created by Katarzyna Kalinowska-Górska on 15.02.2016.
//  Copyright © 2016 kkalinowskagorska. All rights reserved.
//

import UIKit

class KKFullScreenImageGalleryDemoViewController: KKGalleryDemoViewController {

    let image1 = UIImage(named: "photo1")
    let image2 = UIImage(named: "photo2")

// MARK: IBActions
    
    @IBAction func imageModeControlSwitched(_ sender: UISegmentedControl) {
        self.galleryView.reloadCurrentItem()
        self.galleryView.reloadCurrentBottomItem()
    }

// MARK: Gallery view
    
    override func swipeRevealGalleryView(_ galleryView: KKSwipeRevealGalleryView, viewForItemAtIndex index: Int) -> UIView {
        
        func configureImageViewMode(_ imageView : UIImageView){
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
        }
        
        var imageView = self.galleryView.dequeueReusableViewForClass(UIImageView.self) as? UIImageView
        if (imageView == nil){
            imageView = UIImageView()
        }
        
        imageView!.image = index % 2 == 0 ? image1 : image2
        configureImageViewMode(imageView!)
        
        return imageView!
    }
    
}
