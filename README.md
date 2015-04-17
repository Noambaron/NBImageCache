# NBImageCache

[![Version](https://img.shields.io/cocoapods/v/NBImageCache.svg?style=flat)](http://cocoapods.org/pods/NBImageCache)
[![License](https://img.shields.io/cocoapods/l/NBImageCache.svg?style=flat)](http://cocoapods.org/pods/NBImageCache)
[![Platform](https://img.shields.io/cocoapods/p/NBImageCache.svg?style=flat)](http://cocoapods.org/pods/NBImageCache)

## What NBImageChache Does

 * Utilizes Realm.io to store images on disk
 * Retrieves images from cache or from the web, according to availability
 * Lets you save optional meta data alongside each image
 * Leaves all network activity to you
 * Lets you add your functionality in key points through the process 
 * Uses an asynchronous and serial approach processing each image request

## How NBImageCache works

NBImageCache is composed of three main objects. the cache manager, the image request object, and the image file (Realm) object. The image file is the Realm scheme to be saved. The image request object is an abstract vehicle used to process each image operation (save/ retrieve/ delete) and the cache manager is the coordinator and API.


## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Configuring the Image Cache

No special configuration is needed for the cache manager. Only thing you need to do is register the name of the NBImageRequest subclass you will be using.
`[[NBImageCache sharedManager] setImageRequestClass:[YourNBImageRequestSubClass class]];`

## Requirements

## Installation

NBImageCache is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

<!--```ruby-->
<!--pod "NBImageCache"-->
<!--```-->

## Author

Noam Bar-on, bar.on.noam1@gmail.com

## License

<!--NBImageCache is available under the MIT license. See the LICENSE file for more info.-->
<!--=======-->
Fast and asynchronous image cache, based on Realm.io and with a simple block based api
