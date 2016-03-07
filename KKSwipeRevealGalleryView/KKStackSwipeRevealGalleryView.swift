//
//  KKStackSwipeRevealGalleryView.swift
//
//  Created by Katarzyna Kalinowska-Górska on 25.02.2016.
//  Copyright © 2016 kkalinowskagorska. All rights reserved.
//

import UIKit

public class KKStackSwipeRevealGalleryView: KKSwipeRevealGalleryView {
    
    ////////////////////////////////////////////////////////////////////
    // MARK: Public interface
    ////////////////////////////////////////////////////////////////////
    
    // Currently visible view.
    override public var currentItemView : UIView? {
        return currentTopView.subviews.last?.subviews.first
    }
    
    // Doesn't make sense in stack mode. Views are added to the topView.
    override public var currentBottomItemView : UIView? {
        return nil
    }
 
    ////////////////////////////////////////////////////////////////////
    // MARK: Internal data
    ////////////////////////////////////////////////////////////////////
    
    override var currentInteractingView : UIView? {
        get { return currentTopView.subviews.last }
    }
    
    ////////////////////////////////////////////////////////////////////
    // MARK: Setup & view updating
    ////////////////////////////////////////////////////////////////////

    override func setupViews() {

        internalView1.frame = self.bounds
        addSubview(internalView1)
        internalView1.translatesAutoresizingMaskIntoConstraints = true

        currentTopView = internalView1
        currentBottomView = nil
    }
    
    override func layoutSwitchableViews() {
        if !isDragging && !isAnimating {
            currentTopView.frame = self.bounds
            for subview in currentTopView.subviews {
                subview.frame = currentTopView.bounds
                subview.subviews[0].frame = subview.bounds
            }
        }
    }
    
    ////////////////////////////////////////////////////////////////////
    // MARK: Other public API
    ////////////////////////////////////////////////////////////////////
    
    override public func reloadData(){
        
        clearAll()
        currentIndex = 0
        
        if let actualDataSource = dataSource {
            
            numberOfItems = actualDataSource.numberOfItemsInSwipeRevealGalleryView(self)
            guard numberOfItems > 0 else {return}
            for i in (numberOfItems-1).stride(through: 0, by: -1){
                let subviewContainer = UIView()
                let newSubview = actualDataSource.swipeRevealGalleryView(self, viewForItemAtIndex: i)
                subviewContainer.addSubview(newSubview)
                currentTopView.addSubview(subviewContainer)
                subviewContainer.frame = currentTopView.bounds
                newSubview.frame = subviewContainer.bounds
            }
            
        } else {
            numberOfItems = 0
        }
    }
    
    override public func reloadCurrentItem(){
        reloadItemAtIndex(currentIndex)
    }
    
    public func reloadItemAtIndex(index : Int){
        
        guard index < numberOfItems && index >= currentIndex else {
            return
        }

        if let actualDataSource = dataSource {
            
            let subviewIndex = Int(index - currentIndex)
            let subviewContainer = currentTopView.subviews[subviewIndex]
            subviewContainer.subviews[0].removeFromSuperview()
            let newSubview = actualDataSource.swipeRevealGalleryView(self, viewForItemAtIndex: currentIndex)
            subviewContainer.addSubview(newSubview)
            newSubview.frame = subviewContainer.bounds
        }
        
    }
    
    // Doesn't make sense in stack mode
    override public func reloadCurrentBottomItem(){
        // do nothing
    }
    
    ////////////////////////////////////////////////////////////////////
    // MARK: Changing items count
    ////////////////////////////////////////////////////////////////////
    
    //more intuitive name
    public func addItems(nItems : Int){
        increaseItemsCount(nItems)
    }
    
    override public func increaseItemsCount(by: Int){
        guard by > 0 else { return }
        
        let prevNumberOfItems = numberOfItems
        numberOfItems += by
        
        if let actualDataSource = dataSource {
            
            var bottommostView = currentTopView.subviews.first
            
            for i in prevNumberOfItems ..< numberOfItems {
                let newView = actualDataSource.swipeRevealGalleryView(self, viewForItemAtIndex: i)
                let newViewContainer = UIView()
                newViewContainer.addSubview(newView)
                if let actualBottommostView = bottommostView {
                    currentTopView.insertSubview(newViewContainer, belowSubview: actualBottommostView)
                } else {
                    currentTopView.addSubview(newViewContainer)
                }
                
                newViewContainer.frame = currentTopView.bounds
                newView.frame = newViewContainer.bounds
                
                bottommostView = newView
            }
        }
    }

    override public func decreaseItemsCount(by: Int){
        guard by > 0 && by <= numberOfItems else { return }
        
        numberOfItems -= by
        
        for _ in 1 ... by {
            currentTopView.subviews.first?.removeFromSuperview()
        }
        
    }
    
    ////////////////////////////////////////////////////////////////////
    // MARK: Other public API
    ////////////////////////////////////////////////////////////////////
    
    // Doesn't make sense in stack mode
    override public func dequeueReusableViewForClass(reusableViewClass: AnyClass) -> UIView? {
        return nil
    }
    
    ////////////////////////////////////////////////////////////////////
    // MARK: Operations on views
    ////////////////////////////////////////////////////////////////////
    
    override func disableUserInteractionForUnderlyingViews(){
        for i in 1 ..< currentTopView.subviews.count {
            currentTopView.subviews[i].userInteractionEnabled = false
        }
    }
    
    override func switchViews(){
        currentInteractingView?.removeFromSuperview()
        currentInteractingView?.userInteractionEnabled = true
    }
  
    func clearAll(){
        for subview in currentTopView.subviews {
            subview.removeFromSuperview()
        }
    }
}
