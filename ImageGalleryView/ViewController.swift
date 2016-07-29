//
//  ViewController.swift
//  ImageGalleryView
//
//  Created by Benni on 27.07.16.
//  Copyright © 2016 Ben Boecker. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ImageGalleryDelegate {

	override func viewDidLoad() {
		super.viewDidLoad()

		let imageGalleryFrame = CGRect(x: 40, y: 40, width: 300, height: 200)
		let imageGalleryView = ImageGalleryView(frame: imageGalleryFrame)
		imageGalleryView.delegate = self
		imageGalleryView.contentMode = .ScaleAspectFit
		self.view.addSubview(imageGalleryView)
	}

	func numberOfImages(inImageGalleryView galleryView: ImageGalleryView) -> Int {
		return 4
	}

	func imageGalleryView(galleryView: ImageGalleryView, imageCallback callback: ImageCallback, forImageAtIndex index: Int) {
		let image = UIImage(named: "test\(index)")!
		callback(image: image)
	}

	func imageGalleryView(galleryView: ImageGalleryView, didTapImageAtIndex index: Int) {
		print("tapped image at index: \(index)")
	}
}

