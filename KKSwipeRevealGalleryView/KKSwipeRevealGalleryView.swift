//
//  KKSwipeRevealGalleryView.swift
//  KKSwipeRevealGalleryViewDemo
//
//  Created by Katarzyna Kalinowska-Górska on 15.02.2016.
//  Copyright © 2016 kkalinowskagorska. All rights reserved.
//

import UIKit

////////////////////////////////////////////////////////////////////
// MARK: Protocol definitions
////////////////////////////////////////////////////////////////////

public protocol KKSwipeRevealGalleryViewDataSource : class {
    
    func numberOfItemsInSwipeRevealGalleryView(galleryView: KKSwipeRevealGalleryView) -> UInt
    func swipeRevealGalleryView(galleryView: KKSwipeRevealGalleryView, viewForItemAtIndex index: UInt) -> UIView
    
}

@objc public protocol KKSwipeRevealGalleryViewDelegate : class {
    
    optional func swipeRevealGallery(galleryView: KKSwipeRevealGalleryView, didStartSwipingItemAtIndex index: UInt)
    
    optional func swipeRevealGallery(galleryView: KKSwipeRevealGalleryView, didSwipeItemAtIndex index: UInt)
    
    optional func swipeRevealGallery(galleryView: KKSwipeRevealGalleryView, didEndSwipingItemAtIndex index: UInt)
    
    optional func swipeRevealGallery(galleryView: KKSwipeRevealGalleryView, willAnimateItemAtIndex index: UInt, away: Bool)

    optional func swipeRevealGallery(galleryView: KKSwipeRevealGalleryView, didEndAnimatingItemAtIndex index: UInt, away: Bool)
    
    optional func swipeRevealGallery(galleryView: KKSwipeRevealGalleryView, didRevealItemAtIndex index: UInt)
    
    optional func swipeRevealGalleryViewDidSwipeAwayLastItem(galleryView: KKSwipeRevealGalleryView)
    
}

////////////////////////////////////////////////////////////////////
// MARK: Gallery view definition
////////////////////////////////////////////////////////////////////

public class KKSwipeRevealGalleryView : UIView, UIDynamicAnimatorDelegate, UIGestureRecognizerDelegate {

////////////////////////////////////////////////////////////////////
// MARK: Public interface
////////////////////////////////////////////////////////////////////
    
    // If enabled, the last view will reveal the gallery's bottom. Otherwise, the last view will not be swipable.
    @IBInspectable
    public var swipingLastViewEnabled : Bool = true

    // If enabled, the dismissed item view will disappear as soon as the item view get out of bounds. Otherwise, it will fly off screen fully visible. This matters when the gallery view is not full-screen.
    @IBInspectable
    public var viewsDisappearImmediately : Bool = true
    
    // Index for currently visible view. Indexing is refreshed with a call to reloadData.
    private(set) public var currentIndex : UInt = 0
    
    // Number of items (since the last reload, not the current number of items left for swiping)
    private(set) public var numberOfItems : UInt = 0

    // Currently visible view.
    public var currentItemView : UIView? {
        return currentTopView.subviews.first
    }

    // Current bottom view, visible when dragging the top view.
    public var currentBottomItemView : UIView? {
        return currentBottomView.subviews.first
    }
    
    // Data source & delegate.

    public weak var dataSource : KKSwipeRevealGalleryViewDataSource? = nil {
        didSet {
            reloadData()
        }
    }
    
    public weak var delegate : KKSwipeRevealGalleryViewDelegate? = nil
    
    // Gallery's gesture recognizer.
    private(set) public var panGestureRecognizer = UIPanGestureRecognizer()
    
////////////////////////////////////////////////////////////////////
// MARK: Private data
////////////////////////////////////////////////////////////////////
    
    private let internalView1 = UIView()
    private let internalView2 = UIView()
    
    private var currentTopView : UIView!
    private var currentBottomView : UIView!
    
    private var cachedViews = [String : [UIView]]()
    
    private var isDragging = false
    private var isAnimating = false
    
    private var animator : UIDynamicAnimator!
    private var attachmentBehavior : UIAttachmentBehavior? = nil
    private var centerSnapBehavior : UISnapBehavior? = nil
    private var itemBehavior : UIDynamicItemBehavior? = nil
    
    private let MaxCachedViewsForIdentifier = 2
    
////////////////////////////////////////////////////////////////////
// MARK: Initializers
////////////////////////////////////////////////////////////////////
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

////////////////////////////////////////////////////////////////////
// MARK: Setup & view updating
////////////////////////////////////////////////////////////////////
    
    private func setup() {
        animator = UIDynamicAnimator(referenceView: self)
        animator.delegate = self

        internalView1.frame = self.bounds
        internalView2.frame = self.bounds
        
        addSubview(internalView2)
        addSubview(internalView1)
        
        internalView1.translatesAutoresizingMaskIntoConstraints = true
        internalView2.translatesAutoresizingMaskIntoConstraints = true
        
        currentTopView = internalView1
        currentBottomView = internalView2
        
        panGestureRecognizer.delegate = self
        panGestureRecognizer.addTarget(self, action: "detectedPanGesture:")
        
        addGestureRecognizer(panGestureRecognizer)
        
        multipleTouchEnabled = false
    }
    
    override public func layoutSubviews() {
        
        super.layoutSubviews()
        currentBottomView.frame = self.bounds
        currentBottomItemView?.frame = self.bounds
        
        if !isDragging && !isAnimating {
            currentTopView.frame = self.bounds
            currentItemView?.frame = self.bounds
        }
    }
    
////////////////////////////////////////////////////////////////////
// MARK: Other public API
////////////////////////////////////////////////////////////////////

    public func reloadData(){
        
        cachedViews.removeAll()
        currentIndex = 0

        if let actualDataSource = dataSource {
        
            numberOfItems = actualDataSource.numberOfItemsInSwipeRevealGalleryView(self)
            
            if numberOfItems > 0 {
                setItemViewForCurrentTopView(actualDataSource.swipeRevealGalleryView(self, viewForItemAtIndex: currentIndex))
            }
            
            if numberOfItems > 1 {
                setItemViewForCurrentBottomView(actualDataSource.swipeRevealGalleryView(self, viewForItemAtIndex: currentIndex+1))
            }
            
        } else {
            numberOfItems = 0
            clearCurrentTopView()
            clearCurrentBottomView()
        }
    }

    public func reloadCurrentItem(){
        guard currentIndex < numberOfItems else {
            return
        }
        
        if let actualDataSource = dataSource {
            setItemViewForCurrentTopView(actualDataSource.swipeRevealGalleryView(self, viewForItemAtIndex: currentIndex))
        } else {
            clearCurrentTopView()
        }
    }
    
    public func reloadCurrentBottomItem(){
        guard currentIndex < numberOfItems else {
            return
        }
        
        if let actualDataSource = dataSource {
            setItemViewForCurrentBottomView(actualDataSource.swipeRevealGalleryView(self, viewForItemAtIndex: currentIndex+1))
        } else {
            clearCurrentBottomView()
        }
    }

////////////////////////////////////////////////////////////////////
// MARK: Changing items count
////////////////////////////////////////////////////////////////////
    
    func increaseItemsCount(by: UInt){
        guard by > 0 else { return }
        
        let prevNumberOfItems = numberOfItems
        numberOfItems += by
        
        if let actualDataSource = dataSource {
            if currentIndex == prevNumberOfItems {
                setItemViewForCurrentTopView(actualDataSource.swipeRevealGalleryView(self, viewForItemAtIndex: currentIndex))
                if by > 1 {
                    setItemViewForCurrentBottomView(actualDataSource.swipeRevealGalleryView(self, viewForItemAtIndex: currentIndex+1))
                } else {
                    clearCurrentBottomView()
                }
            } else if Int(currentIndex) == Int(prevNumberOfItems) - 1 {
                setItemViewForCurrentBottomView(actualDataSource.swipeRevealGalleryView(self, viewForItemAtIndex: currentIndex+1))
            }
            
        }
    }
    
    func decreaseItemsCount(by: UInt){
        guard by > 0 else { return }

        numberOfItems = by > numberOfItems ? 0 : numberOfItems - by
        
        if numberOfItems < currentIndex + 2 {
            clearCurrentBottomView()
            
            if numberOfItems < currentIndex + 1 {
                clearCurrentTopView()
            }
        }
        
    }
    
    func changeItemsCountTo(newItemsCount: UInt){
        if newItemsCount > numberOfItems {
            increaseItemsCount(newItemsCount - numberOfItems)
        } else if newItemsCount < numberOfItems {
            decreaseItemsCount(numberOfItems - newItemsCount)
        }
    }

    func dequeueReusableViewForClass(reusableViewClass : AnyClass) -> UIView? {
        let identifier = NSStringFromClass(reusableViewClass)
        let dequeuedView = cachedViews[identifier]?.last
        if dequeuedView != nil {
            cachedViews[identifier]?.removeLast()
        }
        return dequeuedView
    }
 
    
////////////////////////////////////////////////////////////////////
// MARK: Gesture recognizer
////////////////////////////////////////////////////////////////////
    
    func detectedPanGesture(gestureRecognizer : UIPanGestureRecognizer) {
        
        let locationInView = gestureRecognizer.locationInView(currentTopView)
     
        switch gestureRecognizer.state {
            
        case .Began:
            
            if !isAnimating && CGRectContainsPoint(currentTopView.bounds, locationInView){
                currentBottomView.userInteractionEnabled = false
                animator.removeAllBehaviors()
                itemBehavior = nil
                attachmentBehavior = UIAttachmentBehavior(item: currentTopView, offsetFromCenter: UIOffsetMake(locationInView.x - currentTopView.bounds.size.width/2, locationInView.y - currentTopView.bounds.size.height/2), attachedToAnchor: gestureRecognizer.locationInView(self))
                animator.addBehavior(attachmentBehavior!)
                isDragging = true
                
                delegate?.swipeRevealGallery?(self, didStartSwipingItemAtIndex: currentIndex)
            }
            
            
        case .Changed:
            
            attachmentBehavior?.anchorPoint = gestureRecognizer.locationInView(self)
            delegate?.swipeRevealGallery?(self, didSwipeItemAtIndex: currentIndex)
            
        case .Ended, .Cancelled, .Failed:
            
            delegate?.swipeRevealGallery?(self, didEndSwipingItemAtIndex: currentIndex)
            if let actualAttachmentBehavior = attachmentBehavior {
                animator.removeBehavior(actualAttachmentBehavior)
                attachmentBehavior = nil
            }
            isDragging = false
            isAnimating = true
            currentTopView.userInteractionEnabled = false
            
            let velocity = gestureRecognizer.velocityInView(self)
            let minVelocityMagnitude : Float = 450
            let velocityMagnitude = sqrtf(Float(velocity.x*velocity.x + velocity.y*velocity.y))
            
            if velocityMagnitude >= minVelocityMagnitude {
                itemBehavior = UIDynamicItemBehavior(items: [currentTopView])
                itemBehavior!.resistance = 1
                itemBehavior!.angularResistance = 1
                weak var weakSelf = self
                itemBehavior!.action = {
                    
                    if let innerSelf = weakSelf {
                        
                        let galleryRootView = innerSelf.rootView()
                        let topViewFrameOnScreen = innerSelf.convertRect(innerSelf.currentTopView.frame, toView: galleryRootView)
                        
                        if (innerSelf.viewsDisappearImmediately && !CGRectIntersectsRect(innerSelf.bounds, innerSelf.currentTopView.frame)) || (!CGRectIntersectsRect(galleryRootView.bounds, topViewFrameOnScreen)) {
                            
                            innerSelf.animator.removeAllBehaviors()
                            innerSelf.isAnimating = false
                            innerSelf.switchViews()
                            innerSelf.currentTopView.userInteractionEnabled = true
                            innerSelf.currentIndex += 1
                            
                            if Int(innerSelf.currentIndex) < Int(innerSelf.numberOfItems) - 1 && innerSelf.dataSource != nil {
                                innerSelf.setItemViewForCurrentBottomView(innerSelf.dataSource!.swipeRevealGalleryView(innerSelf, viewForItemAtIndex: innerSelf.currentIndex+1))
                            } else {
                                innerSelf.clearCurrentBottomView()
                            }
                            
                            if innerSelf.currentIndex < innerSelf.numberOfItems {
                                innerSelf.delegate?.swipeRevealGallery?(innerSelf, didRevealItemAtIndex: innerSelf.currentIndex)
                            } else {
                                innerSelf.delegate?.swipeRevealGalleryViewDidSwipeAwayLastItem?(innerSelf)
                            }

                            innerSelf.delegate?.swipeRevealGallery?(innerSelf, didEndAnimatingItemAtIndex: innerSelf.currentIndex, away: true)
                        }
                    }
                }
                
                itemBehavior!.addLinearVelocity(CGPointMake(velocity.x*2, velocity.y*2), forItem: currentTopView)
                animator.addBehavior(itemBehavior!)
                
                delegate?.swipeRevealGallery?(self, willAnimateItemAtIndex: currentIndex, away: true)
                
            } else {
                UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseInOut, animations: {
                    self.currentTopView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)
                    self.currentTopView.transform = CGAffineTransformIdentity
                    }, completion: {(finished : Bool) -> Void in
                        self.currentTopView.userInteractionEnabled = true
                        self.isAnimating = false
                        self.delegate?.swipeRevealGallery?(self, didEndAnimatingItemAtIndex: self.currentIndex, away: false)
                })
                
                delegate?.swipeRevealGallery?(self, willAnimateItemAtIndex: currentIndex, away: false)
            }
        
        default: break
            
        }
        
    }

    override public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panGestureRecognizer {
            if Int(currentIndex) > Int(numberOfItems) - 1 || (!swipingLastViewEnabled && Int(currentIndex) > Int(numberOfItems) - 2) {
                return false
            }
        }
        return true
    }
    
////////////////////////////////////////////////////////////////////
// MARK: Operations on views
////////////////////////////////////////////////////////////////////
    
    private func switchViews(){
        let tempView = currentBottomView
        currentBottomView = currentTopView
        currentTopView = tempView
        
        bringSubviewToFront(currentTopView)

        currentBottomView.transform = CGAffineTransformIdentity
        currentBottomView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)
    }
    
    private func setItemViewForCurrentTopView(itemView : UIView){
        setItemView(itemView, forView: currentTopView)
    }

    private func setItemViewForCurrentBottomView(itemView : UIView){
        setItemView(itemView, forView: currentBottomView)
    }
    
    private func setItemView(itemView : UIView, forView view : UIView){
        clearView(view)
        
        itemView.frame = view.bounds
        view.addSubview(itemView)
    }
    
    private func clearCurrentTopView(){
        clearView(currentTopView)
    }
    
    private func clearCurrentBottomView(){
        clearView(currentBottomView)
    }
    
    private func clearView(view : UIView){
        
        if let itemView = view.subviews.first {
            cacheItemView(itemView)
            itemView.removeFromSuperview()
        }
        
        view.frame = self.bounds;
    }
    
    private func cacheItemView(itemView : UIView){
        let identifier = NSStringFromClass(itemView.dynamicType)

        if var itemsForIdentifier = cachedViews[identifier] {
            if itemsForIdentifier.count < MaxCachedViewsForIdentifier {
                itemsForIdentifier.append(itemView)
            }
        } else {
            cachedViews[identifier] = [itemView]
        }
    }
}




