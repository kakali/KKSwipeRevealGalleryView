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
//        self.galleryView.increaseItemsCount(2)
    }
    
}


extension KKGalleryDemoViewController : KKSwipeRevealGalleryViewDataSource {
    
    func numberOfItemsInSwipeRevealGalleryView(galleryView: KKSwipeRevealGalleryView) -> Int {
        return 10
    }
    
    func swipeRevealGalleryView(galleryView: KKSwipeRevealGalleryView, viewForItemAtIndex index: Int) -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.randomColor()
        return view
    }
    
}

extension KKGalleryDemoViewController : KKSwipeRevealGalleryViewDelegate {
    
    func swipeRevealGallery(galleryView: KKSwipeRevealGalleryView, didStartSwipingItemAtIndex index: Int){
        NSLog("%@ index = %d", __FUNCTION__, index)
    }
    
    func swipeRevealGallery(galleryView: KKSwipeRevealGalleryView, didSwipeItemAtIndex index: Int){
        NSLog("%@ index = %d", __FUNCTION__, index)
    }
    
    func swipeRevealGallery(galleryView: KKSwipeRevealGalleryView, didEndSwipingItemAtIndex index: Int){
         NSLog("%@ index = %d", __FUNCTION__, index)
    }
    
    func swipeRevealGallery(galleryView: KKSwipeRevealGalleryView, willAnimateItemAtIndex index: Int, away: Bool){
         NSLog("%@ index = %d, away = %@", __FUNCTION__, index, away.description)
    }
    
    func swipeRevealGallery(galleryView: KKSwipeRevealGalleryView, didEndAnimatingItemAtIndex index: Int, away: Bool){
         NSLog("%@ index = %d, away = %@", __FUNCTION__, index, away.description)
    }
    
    func swipeRevealGallery(galleryView: KKSwipeRevealGalleryView, didRevealItemAtIndex index: Int){
         NSLog("%@ index = %d", __FUNCTION__, index)
    }
    
    func swipeRevealGalleryViewDidSwipeAwayLastItem(galleryView: KKSwipeRevealGalleryView){
         NSLog("%@", __FUNCTION__)
    }
    
}
