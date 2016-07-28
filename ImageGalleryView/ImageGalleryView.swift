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
A simple typealias for the image callblack closure used to obtain the images. A callback is used to support asynchronous loading of images.
*/
typealias ImageCallback = (image: UIImage) -> ()

/**
The delegate protocol used for getting information about the content of the `ImageGalleryView`.
*/
@objc protocol ImageGalleryDelegate: class {
	func numberOfImages(inImageGalleryView galleryView: ImageGalleryView) -> Int
	func imageGalleryView(galleryView: ImageGalleryView, imageCallBack callBack: ImageCallback, forImageAtIndex index: Int)
	optional func imageGalleryView(galleryView: ImageGalleryView, didTapImageAtIndex index: Int)
}


class ImageGalleryView: UIView {

	weak var delegate: ImageGalleryDelegate?

	private var collectionView: UICollectionView?
	private var pageControl: UIPageControl?

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.commonInit()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.commonInit()
	}

	override var contentMode: UIViewContentMode {
		didSet {
			super.contentMode = contentMode
			imageContentMode = contentMode
		}
	}
}

extension ImageGalleryView {
	private var cellIdentifier: String {
		return "imageCell"
	}
}

extension ImageGalleryView {
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

	override func layoutSubviews() {
		super.layoutSubviews()

		self.collectionView?.frame = self.bounds
		self.pageControl?.frame = CGRectMake(CGRectGetMinX(self.bounds), CGRectGetMaxY(self.bounds) - 30.0, CGRectGetWidth(self.bounds), 30.0)
	}

	private func updatePageControl() {
		guard let collectionView = self.collectionView, pageControl = self.pageControl else {
			return
		}

		if collectionView.bounds.width > 0 {
			let currentPage = Int((collectionView.contentOffset.x + (collectionView.bounds.width / 2)) / collectionView.bounds.width)
			pageControl.currentPage = currentPage
		} else {
			pageControl.currentPage = 0
		}
	}

	@objc func didTapPageControl(pageControl: UIPageControl) {
		let offset = CGPointMake(CGFloat(pageControl.currentPage) * self.bounds.width, 0.0)
		self.collectionView?.setContentOffset(offset, animated: true)
	}
}


extension ImageGalleryView: UICollectionViewDataSource {
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let numberOfItems = self.delegate?.numberOfImages(inImageGalleryView: self) else {
			return 0
		}

		self.pageControl?.numberOfPages = (numberOfItems > 1) ? numberOfItems : 0

		return numberOfItems
	}

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

		self.delegate?.imageGalleryView(self, imageCallBack: callback, forImageAtIndex: indexPath.row)

		return cell
	}
}

extension ImageGalleryView: UICollectionViewDelegate {
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		self.delegate?.imageGalleryView?(self, didTapImageAtIndex: indexPath.row)
	}
}

extension ImageGalleryView: UIScrollViewDelegate {
	func scrollViewDidScroll(scrollView: UIScrollView) {
		self.updatePageControl()
	}
}

extension ImageGalleryView: UICollectionViewDelegateFlowLayout {
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		return self.bounds.size
	}
}


class ImageCollectionViewCell: UICollectionViewCell {
	var imageView: UIImageView!
	var activityIndicatorView: UIActivityIndicatorView!

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.commonInit()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.commonInit()
	}

	func commonInit() {
		self.clipsToBounds = true

		self.imageView = UIImageView(frame: CGRectZero)
		self.imageView.contentMode = imageContentMode
		self.addSubview(self.imageView)

		self.activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
		self.addSubview(self.activityIndicatorView)
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		self.imageView.frame = self.bounds
//		self.activityIndicatorView.frame = self.bounds
		self.activityIndicatorView.center = self.imageView.center
	}
}



