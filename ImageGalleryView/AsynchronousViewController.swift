//
//  ViewController.swift
//  ImageGalleryView
//
//  Created by Benni on 27.07.16.
//  Copyright © 2016 Ben Boecker. All rights reserved.
//

import UIKit

class AsynchronousViewController: UIViewController, ImageGalleryDelegate {

	@IBOutlet weak var imageGalleryView: ImageGalleryView!

	override func viewDidLoad() {
		super.viewDidLoad()

		self.imageGalleryView.delegate = self
	}

	func numberOfImages(inImageGalleryView galleryView: ImageGalleryView) -> Int {
		return 4
	}

	func imageGalleryView(galleryView: ImageGalleryView) -> ImageCallback {
		return image
	}

	func image(index: Int) -> UIImage {
		return UIImage(named: "test\(index)")!
	}

	func imageGalleryView(galleryView: ImageGalleryView, didTapImageAtIndex index: Int) {
		print("tapped image at index: \(index)")
	}
}

