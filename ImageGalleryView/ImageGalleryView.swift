//
//  ImageGalleryView.swift
//  FH-Survival
//
//  Created by Benni on 25.07.16.
//  Copyright © 2016 Ben Boecker. All rights reserved.
//

import UIKit

/**
Private global variable to store the content mode of the `ImageGalleryView`. This is used so that it can be passed onto the image views in the collection view cells.
*/
private var imageContentMode: UIViewContentMode = .ScaleAspectFill

/**
A simple typealias for the image callback closure used to obtain the images. A callback is used to support asynchronous loading of images.

- parameter image: The image that was loaded and is passed by the delegate.
*/
typealias ImageCallback = (image: UIImage) -> ()

/**
The delegate protocol used for getting information about the content of the `ImageGalleryView`.
*/
@objc protocol ImageGalleryDelegate: class {
	/**
	This method returns the number of images shown in the `ImageGalleryView`. It is required to be implemented by the delegate.
	
	- parameter galleryView: The image gallery instance for that the number of images should be returned.
	- returns: The number of images to be displayed in the given image gallery instance.
	*/
	func numberOfImages(inImageGalleryView galleryView: ImageGalleryView) -> Int
	/**
	This method is responsible for telling the `ImageGalleryView` which images it should display. It does so by providing an `ImageCallback` that **must be called and passed the image by the delegate**. The delegate can determine which image to pass by looking t the passed index.

	- parameter galleryView: The image gallery instance for that the number of images should be returned.
	- parameter callBack: The callback that **must be called by the delegate**. It takes the image that should be displayed at the given index as a parameter.
	- parameter index: The index of the image to be displayed in the image gallery.
	*/
	func imageGalleryView(galleryView: ImageGalleryView, imageCallback callback: ImageCallback, forImageAtIndex index: Int)
	/**
	This method notifies the delegate, that an image was tapped in the `ImageGalleryView`.
	
	- parameter galleryView: The image gallery instance for that the number of images should be returned.
	- parameter index: The index of the image that was tapped.
	*/
	optional func imageGalleryView(galleryView: ImageGalleryView, didTapImageAtIndex index: Int)
}

/**

This class displays a scrollable image gallery. Images are shown one at a time and can be swiped through via paging.

The images are obtained via a delegate protocol that must be implemented in order to show any images. It supports synchronous and asynchronous loading and the images can be shown in any content mode available to `UIView`.

The image gallery can be set via interface builder or in code.

- Author: Benjamin Böcker
- Version: 1.0
*/
final class ImageGalleryView: UIView {
	/// The delegate of the image gallery view, must conform to the `ImageGalleryDelegate` protocol. It's a weak optional to prevent retain cycles.
	weak var delegate: ImageGalleryDelegate?
	/// The internal `UICollectionView` that displays the images.
	private var collectionView: UICollectionView?
	/// The internal `UIPageControl` that displays the index dots.
	private var pageControl: UIPageControl?
	/// The overridden content mode of the view. If a new content mode gets set it is passed to the super class to ensure that the correct functionality remains intact. But the value of the new content mode is also stored in the private global variable `imageContentMode`, so that the images in the collection view can take the same content mode as the image gallery view.
	override var contentMode: UIViewContentMode {
		didSet {
			super.contentMode = contentMode
			imageContentMode = contentMode
		}
	}
	/// The reuse identifier string for the collection view cells
	private var cellIdentifier: String {
		return "imageCell"
	}
	/**
	Overridden initializer if the image gallery view gets created via code. Calls the `commonInit()` method to initialize the subviews and other properties.
	*/
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.commonInit()
	}

	/**
	Required initializer if the image gallery view gets created via interface builder. Calls the `commonInit()` method to initialize the subviews and other properties.
	*/
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.commonInit()
	}
}

extension ImageGalleryView {
	/**
	Initializes all neccessary properties and subviews of the image gallery view.
	*/
	private func commonInit() {
		self.translatesAutoresizingMaskIntoConstraints = false
		self.backgroundColor = UIColor.clearColor()

		self.pageControl = UIPageControl()
		self.pageControl?.currentPage = 0
		self.pageControl?.numberOfPages = 1
		self.pageControl?.hidesForSinglePage = true
		self.pageControl?.addTarget(self, action: #selector(didTapPageControl(_:)), forControlEvents: UIControlEvents.ValueChanged)
		self.pageControl?.userInteractionEnabled = true

		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .Horizontal
		layout.minimumInteritemSpacing = 0
		layout.minimumLineSpacing = 0
		layout.sectionInset = UIEdgeInsetsZero

		self.collectionView = UICollectionView(frame: CGRectNull, collectionViewLayout: layout)
		self.collectionView?.delegate = self
		self.collectionView?.dataSource = self
		self.collectionView?.pagingEnabled = true
		self.collectionView?.translatesAutoresizingMaskIntoConstraints = false
		self.collectionView?.backgroundColor = UIColor.clearColor()
		self.collectionView?.showsHorizontalScrollIndicator = false

		self.collectionView?.registerClass(ImageCollectionViewCell.self, forCellWithReuseIdentifier: self.cellIdentifier)
//		self.collectionView?.registerReuseableCell(ImageCollectionViewCell.self)

		guard let pageControl = self.pageControl, collectionView = self.collectionView else {
			return
		}

		self.addSubview(collectionView)
		self.addSubview(pageControl)
	}

	/**
	Sets the frames of the collection view and the page control depending on the image gallery view bounds.
	*/
	override func layoutSubviews() {
		super.layoutSubviews()

		self.collectionView?.frame = self.bounds
		self.pageControl?.frame = CGRectMake(CGRectGetMinX(self.bounds), CGRectGetMaxY(self.bounds) - 30.0, CGRectGetWidth(self.bounds), 30.0)
	}

	/**
	Updates the current page of the page control depending on the offset of the collection view.
	*/
	private func updatePageControl() {
		guard let collectionView = self.collectionView, pageControl = self.pageControl else {
			return
		}

		let collectionViewWidth = CGRectGetWidth(collectionView.bounds)
		let collectionViewOffset = collectionView.contentOffset.x

		if collectionViewWidth > 0 {
			let currentPage = Int((collectionViewOffset + (collectionViewWidth / 2)) / collectionViewWidth)
			pageControl.currentPage = currentPage
		} else {
			pageControl.currentPage = 0
		}
	}

	/**
	Gets called every time the page control is tapped. The collection view offset is adjusted with an animation to reflect the currently highlighted dot in the page control.
	*/
	@objc func didTapPageControl(pageControl: UIPageControl) {
		let offset = CGPointMake(CGFloat(pageControl.currentPage) * self.bounds.width, 0.0)
		self.collectionView?.setContentOffset(offset, animated: true)
	}

	/**
	Scrolls the `ImageGalleryView` to the specified index if it is within the bounds. Otherwise nothing happens.

	- Parameter atIndex: An `Int` value representing the index of the image to scroll to.
	- Parameter animated: A `Bool` indicating whether the scroll should be animated.
	*/
	func scrollToImage(atIndex: Int, animated: Bool = true) {
		guard atIndex < self.pageControl?.numberOfPages else {
			return
		}

		let indexPath = NSIndexPath(forItem: atIndex, inSection: 0)
		self.collectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: animated)
	}
}

extension ImageGalleryView: UICollectionViewDataSource {
	/**
	UICollectionViewDatasource` method. Asks the image gallery delegate for the number of images.
	*/
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let numberOfItems = self.delegate?.numberOfImages(inImageGalleryView: self) else {
			return 0
		}

		self.pageControl?.numberOfPages = (numberOfItems > 1) ? numberOfItems : 0

		return numberOfItems
	}

	/**
	`UICollectionViewDatasource` method. It asks the delegate to provide the image for a given index by passing a callback closure. That closure updates the cell's image view once the delegate is finished providing the image. This is to make sure the images can be loaded synchronously as well as asynchronously.
	*/
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.cellIdentifier, forIndexPath: indexPath) as? ImageCollectionViewCell else {
			return UICollectionViewCell()
		}

		cell.imageView.image = nil
		cell.activityIndicatorView.startAnimating()
		cell.activityIndicatorView.hidden = false

		let callback: ImageCallback = { image in
			cell.activityIndicatorView.stopAnimating()
			cell.imageView.image = image
		}

		self.delegate?.imageGalleryView(self, imageCallback: callback, forImageAtIndex: indexPath.row)

		return cell
	}
}

extension ImageGalleryView: UICollectionViewDelegate {
	/**
	`UICollectionViewDelegate` method. Tells the image gallery delegate the index of the image that was tapped.
	*/
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		self.delegate?.imageGalleryView?(self, didTapImageAtIndex: indexPath.row)
	}
}

extension ImageGalleryView: UIScrollViewDelegate {
	/**
	`UIScrollViewDelegate` method. Used to catch when the user scrolled in the image gallery to update the page control current page indicator.
	*/
	func scrollViewDidScroll(scrollView: UIScrollView) {
		self.updatePageControl()
	}
}

extension ImageGalleryView: UICollectionViewDelegateFlowLayout {
	/**
	`UICollectionViewDelegateFlowLayout` method. Sets the size of each cell to be the same as the image gallery. One cell is displayed in full at a time.
	*/
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		return self.bounds.size
	}
}

/**
This class represents an image cell that is displayed in the image gallery collection view. It consists of an `UIImageView` and an `ActivityIndicatorView`.
*/
private final class ImageCollectionViewCell: UICollectionViewCell {
	/// The image view that displays the image.
	var imageView: UIImageView!
	/// The activity indicator view that is shown while the image loads.
	var activityIndicatorView: UIActivityIndicatorView!

	/**
	Overridden initializer. Calls the `commonInit()` method to initialize the subviews and other properties.
	*/
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.commonInit()
	}

	/**
	Required initializer. Calls the `commonInit()` method to initialize the subviews and other properties.
	*/
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.commonInit()
	}

	/**
	Initializes all neccessary properties and subviews of the image cell.
	*/
	private func commonInit() {
		self.clipsToBounds = true

		self.imageView = UIImageView(frame: CGRectZero)
		self.imageView.contentMode = imageContentMode
		self.addSubview(self.imageView)

		self.activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
		self.addSubview(self.activityIndicatorView)
	}

	/**
	Sets the frame of the image view to fill the whole cell and centers the activity indicator.
	*/
	override func layoutSubviews() {
		super.layoutSubviews()

		self.imageView.frame = self.bounds
		self.activityIndicatorView.center = self.imageView.center
	}
}



