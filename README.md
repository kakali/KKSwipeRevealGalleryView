# KKSwipeRevealGalleryView
An iOS Swift gallery view where pages are swiped away with the finger. A single page is a custom UIView supplied by the gallery's data source. The top view reveals the next one while it's being swiped. A typical usage example is a full screen image gallery, where the views are UIImages.

For views with transparent background, use KKStackSwipeRevealGalleryView. Keep in mind, though, that all the views must be loaded and displayed on the screen at the same time, so don't get too carried away with adding them!

# Demo screenshots
![screen1](https://cloud.githubusercontent.com/assets/1204385/13333081/75ac5330-dc05-11e5-9a47-7777a7507500.png)
![screen2](https://cloud.githubusercontent.com/assets/1204385/13333080/75a99500-dc05-11e5-89f7-35df491e3d0b.png)

# Installation
You can install KKSwipeRevealGalleryView using CocoaPods. Add the following line to your Podfile:

<code>pod 'KKSwipeRevealGalleryView'</code> 

and perform <code>pod install</code>.

The gallery is now being developed continuously, the version on CocoaPods might not always be the newest one.
