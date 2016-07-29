//
//  ViewController.swift
//  ImageGalleryView
//
//  Created by Benni on 27.07.16.
//  Copyright © 2016 Ben Boecker. All rights reserved.
//

import UIKit

class StoryboardViewController: UIViewController, ImageGalleryDelegate {

	@IBOutlet weak var imageGalleryView: ImageGalleryView!

	override func viewDidLoad() {
		super.viewDidLoad()
		self.imageGalleryView.delegate = self
	}

	func numberOfImages(inImageGalleryView galleryView: ImageGalleryView) -> Int {
		return 4
	}

	func imageGalleryView(galleryView: ImageGalleryView, imageCallback callback: ImageCallback, forImageAtIndex index: Int) {
		let image = UIImage(named: "test\(index)")!
		callback(image: image)
	}

	func imageGalleryView(galleryView: ImageGalleryView) -> ImageCallback {
		return { index in
			return UIImage(named: "test\(index)")!
		}
	}
}

