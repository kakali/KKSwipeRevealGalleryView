//
//  KKStackGalleryDemoViewController.swift
//  KKSwipeRevealGalleryViewDemo
//
//  Created by Katarzyna Kalinowska-Górska on 06.03.2016.
//  Copyright © 2016 kkalinowskagorska. All rights reserved.
//

import UIKit

class KKStackGalleryDemoViewController: KKGalleryDemoViewController {

    @IBOutlet weak var galleryViewWidthConstraint: NSLayoutConstraint!
    var stackedViews : [UIView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stackedViews = self.createViews()
        self.galleryView.reloadData()
    }

    func createViews() -> [UIView] {
        
        var views : [UIView] = []
        let step : CGFloat = 15.0
        var tempWidth = CGFloat(galleryViewWidthConstraint.constant)
        let viewsCount = super.numberOfItemsInSwipeRevealGalleryView(self.galleryView)
        
        for _ in 0 ..< viewsCount {
            let newView = UIView()
            newView.backgroundColor = UIColor.clearColor()
            let newViewContent = UIView()
            newView.addSubview(newViewContent)
            newViewContent.backgroundColor = UIColor.randomColor()
            newViewContent.frame = CGRectMake(0, 0, tempWidth, tempWidth)
            tempWidth -= step
            views.append(newView)
        }
        
        return views.reverse()
    }

    // MARK: Gallery view

    override func numberOfItemsInSwipeRevealGalleryView(galleryView: KKSwipeRevealGalleryView) -> Int {
        return stackedViews.count
    }
    
    override func swipeRevealGalleryView(galleryView: KKSwipeRevealGalleryView, viewForItemAtIndex index: Int) -> UIView {
        return stackedViews[index]
    }
    
    func swipeRevealGallery(galleryView: KKSwipeRevealGalleryView, shouldSwipeCurrentItemTouchedAtPoint point: CGPoint) -> Bool {
        let contentView = galleryView.currentItemView!.subviews[0]
        return CGRectContainsPoint(contentView.frame, point)
    }
}
