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
            newView.backgroundColor = UIColor.clear
            let newViewContent = UIView()
            newView.addSubview(newViewContent)
            newViewContent.backgroundColor = UIColor.randomColor()
            newViewContent.frame = CGRect(x: 0, y: 0, width: tempWidth, height: tempWidth)
            tempWidth -= step
            views.append(newView)
        }
        
        return views.reversed()
    }

    // MARK: Gallery view

    override func numberOfItemsInSwipeRevealGalleryView(_ galleryView: KKSwipeRevealGalleryView) -> Int {
        return stackedViews.count
    }
    
    override func swipeRevealGalleryView(_ galleryView: KKSwipeRevealGalleryView, viewForItemAtIndex index: Int) -> UIView {
        return stackedViews[index]
    }
    
    func swipeRevealGallery(_ galleryView: KKSwipeRevealGalleryView, shouldSwipeCurrentItemTouchedAtPoint point: CGPoint) -> Bool {
        let contentView = galleryView.currentItemView!.subviews[0]
        return contentView.frame.contains(point)
    }
}
