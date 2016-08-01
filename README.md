# ImageGalleryView

## Description

A custom image gallery view for iOS written in Swift. It displays a range of images one at a time, swipable and with a page indicator at the bottom. The images are provided via delegate methods.

## Installation

Clone or download the repository and and manually add the file `ImageGalleryView.swift` to your project and target.

## Usage

The gallery view can be used with storyboards or be created in code. 

```
let imageGalleryFrame = CGRect(x: 40, y: 40, width: 300, height: 200)
let imageGalleryView = ImageGalleryView(frame: imageGalleryFrame)
imageGalleryView.delegate = self
self.view.addSubview(imageGalleryView)
```

Either way, the delegate must be set.



