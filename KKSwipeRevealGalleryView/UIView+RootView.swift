//
//  UIView+RootView.swift
//  KKSwipeRevealGalleryViewDemo
//
//  Created by Katarzyna Kalinowska-Górska on 21.02.2016.
//  Copyright © 2016 kkalinowskagorska. All rights reserved.
//

import UIKit

extension UIView {
    
    func rootView() -> UIView {
        
        var tempView = self

        while let tempViewSuperview = tempView.superview {
            tempView = tempViewSuperview
        }
        
        return tempView
    }
    
}
