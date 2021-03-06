//
//  KKMiscGalleryDemoViewController.swift
//  KKSwipeRevealGalleryViewDemo
//
//  Created by Katarzyna Kalinowska-Górska on 15.02.2016.
//  Copyright © 2016 kkalinowskagorska. All rights reserved.
//

import UIKit

class KKMiscGalleryDemoViewController: KKGalleryDemoViewController {

    let image1 = UIImage(named: "photo1")
    let image2 = UIImage(named: "photo2")

// MARK: IBActions
    
    @IBAction func lastViewSwipeableSwitchSwitched(_ sender: UISwitch) {
        self.galleryView.swipingLastViewEnabled = sender.isOn
    }
    
    @IBAction func disappearsImmediatelySwitchSwitched(_ sender: UISwitch) {
        self.galleryView.viewsDisappearImmediately = sender.isOn
    }
    
// MARK: Gallery view

    override func swipeRevealGalleryView(_ galleryView: KKSwipeRevealGalleryView, viewForItemAtIndex index: Int) -> UIView {
        let randNumber = arc4random_uniform(3)
        var view : UIView? = nil

        switch randNumber {
        case 0:
            var imageView = self.galleryView.dequeueReusableViewForClass(UIImageView.self) as? UIImageView
            if imageView == nil {
                imageView = UIImageView()
                imageView!.contentMode = .scaleAspectFill
                imageView!.clipsToBounds = true
            }
            
            imageView?.image = index % 2 == 0 ? image1 : image2
            view = imageView
            
        case 1:
            var webView = self.galleryView.dequeueReusableViewForClass(UIWebView.self) as? UIWebView
            if webView == nil {
                webView = UIWebView()
                webView?.isUserInteractionEnabled = false
            }
            webView?.loadHTMLString(String(format: "<body style=\"background-color:rgb(%d,%d,%d)\"><h2>index = %lu</h2></body>", arc4random_uniform(256),arc4random_uniform(256),arc4random_uniform(256),index), baseURL: nil)
            view = webView
            
        case 2:
            var galleryItemView = self.galleryView.dequeueReusableViewForClass(KKSwipeRevealGalleryViewDemo.KKGalleryItemView) as? KKGalleryItemView
            if galleryItemView == nil {
                galleryItemView = (Bundle.main.loadNibNamed("KKGalleryItemView", owner:nil , options: nil)!.first as! KKGalleryItemView)
            }
            
            galleryItemView!.backgroundColor = UIColor.randomColor()
            galleryItemView!.button.backgroundColor = UIColor.randomColor()
            view = galleryItemView
            
        default:
            view = UIView()
            view?.backgroundColor = UIColor.randomColor()
        }
        
        return view!
    }
    
}
