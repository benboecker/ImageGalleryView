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

	let imageURLs: [NSURL] = [NSURL(string: "https://placekitten.com/g/200/300")!,
	                          NSURL(string: "https://placekitten.com/g/230/480")!,
	                          NSURL(string: "https://placekitten.com/g/600/500")!,
	                          NSURL(string: "https://placekitten.com/g/1000/1800")!,
	                          NSURL(string: "https://placekitten.com/g/850/1300")!,
	                          ]

	override func viewDidLoad() {
		super.viewDidLoad()

		self.imageGalleryView.delegate = self
	}

	func numberOfImages(inImageGalleryView galleryView: ImageGalleryView) -> Int {
		return self.imageURLs.count
	}


	func imageGalleryView(galleryView: ImageGalleryView, imageCallBack callBack: ImageCallback, forImageAtIndex index: Int) {
		let url = self.imageURLs[index]

		NSURLSession.sharedSession().dataTaskWithURL(url) { (data, _, error) in
			dispatch_async(dispatch_get_main_queue()) {
				guard let data = data else {
					return
				}

				let image = UIImage(data: data)!
				callBack(image: image)
			}
			}.resume()
	}

	func imageGalleryView(galleryView: ImageGalleryView, didTapImageAtIndex index: Int) {
		print("tapped image at index: \(index)")
	}
}

