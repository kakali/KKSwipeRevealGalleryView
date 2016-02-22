//
//  UIColor+RandomColor.swift
//  KKSwipeRevealGalleryViewDemo
//
//  Created by Katarzyna Kalinowska-Górska on 20.02.2016.
//  Copyright © 2016 kkalinowskagorska. All rights reserved.
//

import UIKit

extension UIColor {
    
    static func randomColor() -> UIColor {
        
        return UIColor(red: CGFloat(Double(arc4random_uniform(256))/255.0), green: CGFloat(Double(arc4random_uniform(256))/255.0), blue: CGFloat(Double(arc4random_uniform(256))/255.0), alpha: 1)
        
    }
    
}
