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
        galleryView.backgroundColor = UIColor.clear
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
    
    func numberOfItemsInSwipeRevealGalleryView(_ galleryView: KKSwipeRevealGalleryView) -> Int {
        return 10
    }
    
    func swipeRevealGalleryView(_ galleryView: KKSwipeRevealGalleryView, viewForItemAtIndex index: Int) -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.randomColor()
        return view
    }
    
}

extension KKGalleryDemoViewController : KKSwipeRevealGalleryViewDelegate {
    
    func swipeRevealGallery(_ galleryView: KKSwipeRevealGalleryView, didStartSwipingItemAtIndex index: Int){
        NSLog("%@ index = %d", #function, index)
    }
    
    func swipeRevealGallery(_ galleryView: KKSwipeRevealGalleryView, didSwipeItemAtIndex index: Int){
        NSLog("%@ index = %d", #function, index)
    }
    
    func swipeRevealGallery(_ galleryView: KKSwipeRevealGalleryView, didEndSwipingItemAtIndex index: Int){
         NSLog("%@ index = %d", #function, index)
    }
    
    func swipeRevealGallery(_ galleryView: KKSwipeRevealGalleryView, willAnimateItemAtIndex index: Int, away: Bool){
         NSLog("%@ index = %d, away = %@", #function, index, away.description)
    }
    
    func swipeRevealGallery(_ galleryView: KKSwipeRevealGalleryView, didEndAnimatingItemAtIndex index: Int, away: Bool){
         NSLog("%@ index = %d, away = %@", #function, index, away.description)
    }
    
    func swipeRevealGallery(_ galleryView: KKSwipeRevealGalleryView, didRevealItemAtIndex index: Int){
         NSLog("%@ index = %d", #function, index)
    }
    
    func swipeRevealGalleryViewDidSwipeAwayLastItem(_ galleryView: KKSwipeRevealGalleryView){
         NSLog("%@", #function)
    }
    
}
