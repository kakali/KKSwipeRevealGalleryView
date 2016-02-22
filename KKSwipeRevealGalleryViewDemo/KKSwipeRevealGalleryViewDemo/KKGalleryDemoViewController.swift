//
//  KKGalleryDemoViewController.swift
//  KKSwipeRevealGalleryViewDemo
//
//  Created by Katarzyna Kalinowska-Górska on 15.02.2016.
//  Copyright © 2016 kkalinowskagorska. All rights reserved.
//

import UIKit

class KKGalleryDemoViewController: UIViewController {

    @IBOutlet weak var galleryView: KKSwipeRevealGalleryView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        galleryView.backgroundColor = UIColor.clearColor()
        galleryView.dataSource = self
        galleryView.delegate = self
        
        self.galleryView.reloadData()
    }
    
    @IBAction func reloadGalleryButtonTapped() {
        self.galleryView.reloadData()
    }
    
}


extension KKGalleryDemoViewController : KKSwipeRevealGalleryViewDataSource {
    
    func numberOfItemsInSwipeRevealGalleryView(galleryView: KKSwipeRevealGalleryView) -> UInt {
        return 10
    }
    
    func swipeRevealGalleryView(galleryView: KKSwipeRevealGalleryView, viewForItemAtIndex index: UInt) -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.randomColor()
        return view
    }
    
}

extension KKGalleryDemoViewController : KKSwipeRevealGalleryViewDelegate {
    
    func swipeRevealGallery(galleryView: KKSwipeRevealGalleryView, didStartSwipingItemAtIndex index: UInt){
        NSLog("%s index = %lu", __FUNCTION__, index)
    }
    
    func swipeRevealGallery(galleryView: KKSwipeRevealGalleryView, didSwipeItemAtIndex index: UInt){
        NSLog("%s index = %lu", __FUNCTION__, index)
    }
    
    func swipeRevealGallery(galleryView: KKSwipeRevealGalleryView, didEndSwipingItemAtIndex index: UInt){
         NSLog("%s index = %lu", __FUNCTION__, index)
    }
    
    func swipeRevealGallery(galleryView: KKSwipeRevealGalleryView, willAnimateItemAtIndex index: UInt, away: Bool){
         NSLog("%s index = %lu, away = %@", __FUNCTION__, index, away.description)
    }
    
    func swipeRevealGallery(galleryView: KKSwipeRevealGalleryView, didEndAnimatingItemAtIndex index: UInt, away: Bool){
         NSLog("%s index = %lu, away = %@", __FUNCTION__, index, away.description)
    }
    
    func swipeRevealGallery(galleryView: KKSwipeRevealGalleryView, didRevealItemAtIndex index: UInt){
         NSLog("%s index = %lu", __FUNCTION__, index)
    }
    
    func swipeRevealGalleryViewDidSwipeAwayLastItem(galleryView: KKSwipeRevealGalleryView){
         NSLog("%s", __FUNCTION__)
    }
    
}
