//
//  KKSwipeRevealGalleryView.swift
//
//  Created by Katarzyna Kalinowska-Górska on 15.02.2016.
//  Copyright © 2016 kkalinowskagorska. All rights reserved.
//

import UIKit

////////////////////////////////////////////////////////////////////
// MARK: Protocol definitions
////////////////////////////////////////////////////////////////////

public protocol KKSwipeRevealGalleryViewDataSource : class {
    
    func numberOfItemsInSwipeRevealGalleryView(_ galleryView: KKSwipeRevealGalleryView) -> Int
    func swipeRevealGalleryView(_ galleryView: KKSwipeRevealGalleryView, viewForItemAtIndex index: Int) -> UIView
    
}

@objc public protocol KKSwipeRevealGalleryViewDelegate : class {
    
    @objc optional func swipeRevealGallery(_ galleryView: KKSwipeRevealGalleryView, didStartSwipingItemAtIndex index: Int)
    
    @objc optional func swipeRevealGallery(_ galleryView: KKSwipeRevealGalleryView, didSwipeItemAtIndex index: Int)
    
    @objc optional func swipeRevealGallery(_ galleryView: KKSwipeRevealGalleryView, didEndSwipingItemAtIndex index: Int)
    
    @objc optional func swipeRevealGallery(_ galleryView: KKSwipeRevealGalleryView, willAnimateItemAtIndex index: Int, away: Bool)

    @objc optional func swipeRevealGallery(_ galleryView: KKSwipeRevealGalleryView, didEndAnimatingItemAtIndex index: Int, away: Bool)
    
    @objc optional func swipeRevealGallery(_ galleryView: KKSwipeRevealGalleryView, didRevealItemAtIndex index: Int)
    
    @objc optional func swipeRevealGalleryViewDidSwipeAwayLastItem(_ galleryView: KKSwipeRevealGalleryView)
    
    @objc optional func swipeRevealGallery(_ galleryView: KKSwipeRevealGalleryView, shouldSwipeCurrentItemTouchedAtPoint point: CGPoint) -> Bool
    
    @objc optional func minimalVelocityToSwipeAwayCurrentItemInSwipeRevealGallery(_ galleryView: KKSwipeRevealGalleryView) -> CGFloat
    
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
    
    // If set to true, the view will use snap behavior to go back to the center.
    @IBInspectable
    public var snapAnimation : Bool = true
    
    // Snap animation damping property.
    @IBInspectable
    public var snapAnimationDamping : CGFloat = 0.5
    
    // IF no snap enabled, this is the duration of the simple returning animation.
    private var simpleAnimationDuration = 0.3
    
    // Index for currently visible view. Indexing is refreshed with a call to reloadData.
    internal(set) public var currentIndex : Int = 0
    
    // Number of items (since the last reload, not the current number of items left for swiping)
    internal(set) public var numberOfItems : Int = 0

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
    internal(set) public var panGestureRecognizer = UIPanGestureRecognizer()
    
////////////////////////////////////////////////////////////////////
// MARK: Internal data
////////////////////////////////////////////////////////////////////
    
    let internalView1 = UIView()
    let internalView2 = UIView()
    
    var currentTopView : UIView!
    var currentBottomView : UIView!
    
    var currentInteractingView : UIView? {
        get { return currentTopView }
    }
    
    var cachedViews = [String : [UIView]]()
    
    var isDragging = false
    var isAnimatingAway = false
    var isAnimatingToCenter = false
    var isAnimating : Bool {
        get {
            return isAnimatingAway || isAnimatingToCenter
        }
    }
    
    lazy var animator : UIDynamicAnimator! = {
        let lazyAnimator = UIDynamicAnimator(referenceView: self)
        lazyAnimator.delegate = self
        return lazyAnimator
    }()
    
    var attachmentBehavior : UIAttachmentBehavior? = nil
    var centerSnapBehavior : UISnapBehavior? = nil
    var itemBehavior : UIDynamicItemBehavior? = nil
    
////////////////////////////////////////////////////////////////////
// MARK: Defaults, constants
////////////////////////////////////////////////////////////////////
    
    struct InternalDefaults {
        static let MinVelocityMagnitude : CGFloat = 700.0
        static let MaxCachedViewsForIdentifier = 2
        static let CenterAnimationDuration = 0.3
        static let FadeOutAnimationDuration = 0.1
    }
    
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
    
    func setup() {
        setupViews()
        setupGestureRecognition()
    }
    
    func setupViews(){
        internalView1.frame = self.bounds
        internalView2.frame = self.bounds
        
        addSubview(internalView2)
        addSubview(internalView1)
        
        internalView1.translatesAutoresizingMaskIntoConstraints = true
        internalView2.translatesAutoresizingMaskIntoConstraints = true
        
        currentTopView = internalView1
        currentBottomView = internalView2
    }
    
    func setupGestureRecognition(){
        panGestureRecognizer.delegate = self
        panGestureRecognizer.addTarget(self, action: #selector(KKSwipeRevealGalleryView.detectedPanGesture(_:)))
        addGestureRecognizer(panGestureRecognizer)
        isMultipleTouchEnabled = false
    }
    
    override public func layoutSubviews() {
        
        super.layoutSubviews()
        layoutSwitchableViews()
    }
    
    func layoutSwitchableViews(){
        currentBottomView.frame = self.bounds
        currentBottomItemView?.frame = currentBottomView.bounds
        
        if !isDragging && !isAnimating {
            currentTopView.frame = self.bounds
            currentItemView?.frame = currentTopView.bounds
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
                setItemViewForCurrentTopView(actualDataSource.swipeRevealGalleryView(self, viewForItemAtIndex: currentIndex), cacheOld: false)
            }
            
            if numberOfItems > 1 {
                setItemViewForCurrentBottomView(actualDataSource.swipeRevealGalleryView(self, viewForItemAtIndex: currentIndex+1), cacheOld: false)
            }
            
        } else {
            numberOfItems = 0
            clearCurrentTopView(cache: false)
            clearCurrentBottomView(cache: false)
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
    
    public func increaseItemsCount(_ by: Int){
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
            } else if currentIndex == prevNumberOfItems - 1 {
                setItemViewForCurrentBottomView(actualDataSource.swipeRevealGalleryView(self, viewForItemAtIndex: currentIndex+1))
            }
            
        }
    }
    
    public func decreaseItemsCount(_ by: Int){
        guard by > 0 else { return }

        numberOfItems = by > numberOfItems ? 0 : numberOfItems - by
        
        if numberOfItems < currentIndex + 2 {
            clearCurrentBottomView()
            
            if numberOfItems < currentIndex + 1 {
                clearCurrentTopView()
            }
        }
        
    }
    
    public func changeItemsCountTo(_ newItemsCount: Int){
        if newItemsCount > numberOfItems {
            increaseItemsCount(newItemsCount - numberOfItems)
        } else if newItemsCount < numberOfItems {
            decreaseItemsCount(numberOfItems - newItemsCount)
        }
    }

    public func dequeueReusableViewForClass(_ reusableViewClass : AnyClass) -> UIView? {
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
    
    func detectedPanGesture(_ gestureRecognizer : UIPanGestureRecognizer) {
        
        guard currentInteractingView != nil else { return }
        
        let swipeableView = currentInteractingView!
        let locationInView = gestureRecognizer.location(in: swipeableView)
     
        switch gestureRecognizer.state {
            
        case .began:
            
            if !isAnimating && swipeableView.bounds.contains(locationInView){
                disableUserInteractionForUnderlyingViews()
                animator.removeAllBehaviors()
                itemBehavior = nil
                attachmentBehavior = UIAttachmentBehavior(item: swipeableView, offsetFromCenter: UIOffsetMake(locationInView.x - swipeableView.bounds.size.width/2, locationInView.y - swipeableView.bounds.size.height/2), attachedToAnchor: gestureRecognizer.location(in: self))
                animator.addBehavior(attachmentBehavior!)
                isDragging = true
                
                delegate?.swipeRevealGallery?(self, didStartSwipingItemAtIndex: currentIndex)
            }
            
            
        case .changed:
            
            attachmentBehavior?.anchorPoint = gestureRecognizer.location(in: self)
            delegate?.swipeRevealGallery?(self, didSwipeItemAtIndex: currentIndex)
            
        case .ended, .cancelled, .failed:
            
            delegate?.swipeRevealGallery?(self, didEndSwipingItemAtIndex: currentIndex)
            if let actualAttachmentBehavior = attachmentBehavior {
                animator.removeBehavior(actualAttachmentBehavior)
                attachmentBehavior = nil
            }
            isDragging = false
            swipeableView.isUserInteractionEnabled = false
            
            let velocity = gestureRecognizer.velocity(in: self)
            var minVelocityMagnitude = delegate?.minimalVelocityToSwipeAwayCurrentItemInSwipeRevealGallery?(self)
            if minVelocityMagnitude == nil {
               minVelocityMagnitude = InternalDefaults.MinVelocityMagnitude
            }
            
            let velocityMagnitude = CGFloat(sqrtf(Float(velocity.x*velocity.x + velocity.y*velocity.y)))
            
            let centerPoint = CGPoint(x: self.bounds.midX, y: self.bounds.midY)

            let swipingBack = (swipeableView.center.x > centerPoint.x && velocity.x < 0) || (swipeableView.center.x < centerPoint.x && velocity.x > 0)
                || (swipeableView.center.y > centerPoint.y && velocity.y < 0) || (swipeableView.center.y < centerPoint.y && velocity.y > 0)
            
            if velocityMagnitude >= minVelocityMagnitude! && !swipingBack {
                
                isAnimatingAway = true
                itemBehavior = UIDynamicItemBehavior(items: [swipeableView])
                itemBehavior!.resistance = 1
                itemBehavior!.angularResistance = 1

                itemBehavior!.action = { [unowned self] in
                        
                    let galleryRootView = self.rootView()
                    let topViewFrameOnScreen = self.convert(swipeableView.frame, to: galleryRootView)
                    
                    if (self.viewsDisappearImmediately && !self.bounds.intersects(swipeableView.frame)) || (!galleryRootView.bounds.intersects(topViewFrameOnScreen)) {
                        self.onFinishedAnimatingAway()
                    }
                }
                
                itemBehavior!.addLinearVelocity(CGPoint(x: velocity.x*2, y: velocity.y*2), for: swipeableView)
                animator.addBehavior(itemBehavior!)
                
                delegate?.swipeRevealGallery?(self, willAnimateItemAtIndex: currentIndex, away: true)
                
            } else {
                
                isAnimatingToCenter = true
                
                if snapAnimation == true {
                    let centerPoint = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
                    let snapBehavior = UISnapBehavior(item: swipeableView, snapTo: centerPoint)
                    snapBehavior.damping = min(max(snapAnimationDamping, 0), 1.0)
                    snapBehavior.action = { [unowned self] in
                        if swipeableView.center == centerPoint {
                            self.animator.removeAllBehaviors()
                            swipeableView.isUserInteractionEnabled = true
                            self.isAnimatingToCenter = false
                            self.delegate?.swipeRevealGallery?(self, didEndAnimatingItemAtIndex: self.currentIndex, away: false)

                        }
                    }
                    animator.addBehavior(snapBehavior)
                } else {
                    UIView.animate(withDuration: InternalDefaults.CenterAnimationDuration, delay: 0, options: .curveEaseInOut, animations: {
                        swipeableView.center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
                        swipeableView.transform = CGAffineTransform.identity
                        }, completion: {(finished : Bool) -> Void in
                            swipeableView.isUserInteractionEnabled = true
                            self.isAnimatingToCenter = false
                            self.delegate?.swipeRevealGallery?(self, didEndAnimatingItemAtIndex: self.currentIndex, away: false)
                    })
                }
                
                delegate?.swipeRevealGallery?(self, willAnimateItemAtIndex: currentIndex, away: false)
            }
        
        default: break
            
        }
        
    }

    override public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panGestureRecognizer {
            if currentIndex > numberOfItems - 1 || (!swipingLastViewEnabled && currentIndex > numberOfItems - 2) {
                return false
            }
            let swipingAllowedByDelegate = self.delegate?.swipeRevealGallery?(self, shouldSwipeCurrentItemTouchedAtPoint: panGestureRecognizer.location(in: currentInteractingView!))
            if let swipingAllowed = swipingAllowedByDelegate {
                return swipingAllowed
            }
        }
        return true
    }

    func onFinishedAnimatingAway(){
        
        func cleanUpBehaviors() {
            self.animator.removeAllBehaviors()
            self.itemBehavior = nil
        }
        
        func performLogic(){
            self.isAnimatingAway = false
            self.currentIndex += 1
            self.switchViews()
        }
        
        func callDelegateMethods(){
            if self.currentIndex < self.numberOfItems {
                self.delegate?.swipeRevealGallery?(self, didRevealItemAtIndex: self.currentIndex)
            } else {
                self.delegate?.swipeRevealGalleryViewDidSwipeAwayLastItem?(self)
            }
            
            self.delegate?.swipeRevealGallery?(self, didEndAnimatingItemAtIndex: self.currentIndex-1, away: true)
        }
        
        cleanUpBehaviors()
        performLogic()
        callDelegateMethods()
    }
    

    
////////////////////////////////////////////////////////////////////
// MARK: Dynamic animator delegate
////////////////////////////////////////////////////////////////////
    
    public func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        if isAnimatingAway == true { //if the animation hasn't been finished correcly using item behavior action closure, clean up here
            UIView.animate(withDuration: InternalDefaults.FadeOutAnimationDuration, animations: {
                self.currentInteractingView?.alpha = 0
                }, completion: {(finished) in
                    self.onFinishedAnimatingAway()
            })
        }
    }
    
////////////////////////////////////////////////////////////////////
// MARK: Operations on views
////////////////////////////////////////////////////////////////////
    
    func disableUserInteractionForUnderlyingViews(){
        currentBottomView.isUserInteractionEnabled = false
    }
    
    func switchViews(){
        let tempView = currentBottomView
        currentBottomView = currentTopView
        currentTopView = tempView
        
        bringSubview(toFront: currentTopView)

        currentBottomView.transform = CGAffineTransform.identity
        currentBottomView.center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
        
        currentTopView.isUserInteractionEnabled = true
        
        if self.currentIndex < self.numberOfItems - 1 && self.dataSource != nil {
            self.setItemViewForCurrentBottomView(self.dataSource!.swipeRevealGalleryView(self, viewForItemAtIndex: self.currentIndex+1))
        } else {
            self.clearCurrentBottomView()
        }
    }
    
    func setItemViewForCurrentTopView(_ itemView : UIView){
        setItemView(itemView, forView: currentTopView, cacheOld: true)
    }

    func setItemViewForCurrentBottomView(_ itemView : UIView){
        setItemView(itemView, forView: currentBottomView, cacheOld: true)
    }

    func setItemViewForCurrentTopView(_ itemView : UIView, cacheOld: Bool){
        setItemView(itemView, forView: currentTopView, cacheOld: cacheOld)
    }
    
    func setItemViewForCurrentBottomView(_ itemView : UIView, cacheOld: Bool){
        setItemView(itemView, forView: currentBottomView, cacheOld: cacheOld)
    }
    
    func setItemView(_ itemView : UIView, forView view : UIView, cacheOld: Bool){
        clearView(view, cache: cacheOld)
        
        itemView.frame = view.bounds
        view.addSubview(itemView)
    }
    
    func clearCurrentTopView(){
        clearView(currentTopView, cache: true)
    }
    
    func clearCurrentBottomView(){
        clearView(currentBottomView, cache: true)
    }

    func clearCurrentTopView(cache: Bool){
        clearView(currentTopView, cache: cache)
    }
    
    func clearCurrentBottomView(cache: Bool){
        clearView(currentBottomView, cache: cache)
    }
    
    func clearView(_ view : UIView, cache: Bool){
        
        if let itemView = view.subviews.first {
            if cache {
                cacheItemView(itemView)
            }
            itemView.removeFromSuperview()
        }
        
        view.frame = self.bounds;
    }
    
    func cacheItemView(_ itemView : UIView){
        let identifier = NSStringFromClass(itemView.dynamicType)

        if let itemsForIdentifier = cachedViews[identifier] {
            if itemsForIdentifier.count < InternalDefaults.MaxCachedViewsForIdentifier {
                cachedViews[identifier]?.append(itemView)
            }
        } else {
            cachedViews[identifier] = [itemView]
        }
    }
}




