# ImageGalleryView

![Screenshot](https://github.com/bennibrightside/ImageGalleryView/blob/master/screenshot.jpg)

## Description

A custom image gallery view for iOS written in Swift. It displays a range of images one at a time, swipable and with a page indicator at the bottom. The images are provided via delegate methods and can be loaded synchronously or asynchronously (via a webservice).

## Installation

Clone or download the repository and and manually add the file `ImageGalleryView.swift` to your project and target.

## Usage

The gallery view can be used with storyboards or be created in code. Either way, the delegate must be set in code.

```
let imageGalleryFrame = CGRect(x: 40, y: 40, width: 300, height: 200)
let imageGalleryView = ImageGalleryView(frame: imageGalleryFrame)
imageGalleryView.delegate = self // Must be set for the control to work!
self.view.addSubview(imageGalleryView)
```

The images get displayed with the same content mode as the `ImageGalleryView`, the default is `.ScaleAspectFill`. This can also be set via interface builder or in code.


## ImageGalleryDelegate

The delegate protocol defines some required methods to implement.

`func numberOfImages(inImageGalleryView galleryView: ImageGalleryView) -> Int`

This method returns the number of images shown in the `ImageGalleryView`. It is required to be implemented by the delegate.

`func imageGalleryView(galleryView: ImageGalleryView, imageCallback callback: ImageCallback, forImageAtIndex index: Int)`

This method is responsible for telling the `ImageGalleryView` which images it should display. It does so by providing an `ImageCallback` that **must be called and passed the image by the delegate**. The delegate can determine which image to pass by looking at the given index.

`optional func imageGalleryView(galleryView: ImageGalleryView, didTapImageAtIndex index: Int)`

This method notifies the delegate, that an image was tapped in the `ImageGalleryView`. It is an optional method that doesn't need to be implemented.

## Contact

[apps@ben-boecker.de](mailto:apps@ben-boecker.de)  

[@BenBoecker](https://twitter.com/BenBoecker)

## License

ImageGalleryView is available under the [MIT License](https://github.com/bennibrightside/ImageGalleryView/blob/master/LICENSE)