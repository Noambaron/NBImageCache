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
```ruby
[[NBImageCache sharedManager] setImageRequestClass:[YourNBImageRequestSubClass class]];
```
`
## Subclassing NBImageRequest

NBImageRequest is an abstract object that is used as a vehicle for all image processing. Note that the Image is an entity that is uniquely identified by both a file_id AND a size in the image cache. You must subclass NBImageRequest and implement these two imageRequest lifeCycle abstract methods:

```ruby
//in your MYNBImageRequest.h
#import "NBImageRequest.h"

@interface MYNBImageRequest : NBImageRequest

-(void) imageRequest:(NBImageRequest *)request isAskingForImageWithFileId:(long)file_id withCompletion:(void (^)(long file_id, UIImage * returnedImage))completionBlock;

-(void) willSaveImageWithRequest:(NBImageRequest *)request withCompletion:(void (^)(long file_id, NSError * error))completionBlock;

@end
```
`
```ruby
//in your MYNBImageRequest.m

-(void) imageRequest:(NBImageRequest *)request isAskingForImageWithFileId:(long)file_id withCompletion:(void (^)(long file_id, UIImage * returnedImage))completionBlock {
//do what ever you need to get the image. then call:

completionBlock(file_id, image);    

}
```
`
This is a mandatory abstract method. Add here the code for any network activity to get the image for the given file id. this method will only be called once for every file id and size, because once it retrieves an image from server, the image will be cached in memory and on disk.

```ruby
-(void) willSaveImageWithRequest:(NBImageRequest *)request withCompletion:(void (^)(long file_id, NSError * error))completionBlock {    

//add here any code you need to run before image is saved in cache. must call completion block and return a file_id 

completionBlock(file_id, nil);

}
```
`

This is a mandatory abstract method. Add here any processing you need to execute before intire save operation is complete. for example use this to compress the image and send it to the server to get back any metadata about it (like an id maybe..). you can also adjust the metadata object and the image, any changes to the request, image or metadata will be saved. Once done, you must call the completion block and include a file id.

## Providing Source Images to NBImageCache

Normally there is no need to manually save images, as any image downloaded through the cache manager will be automatically saved. But if you need to manually insert an image you can do the following:
```ruby
-(void) saveImage:(UIImage *)image andMetaData:(NSDictionary *)metaData {


[[NBImageCache sharedManager] saveImage:image metaData:metaData withCompletion:^(BOOL success, UIImage *savedImage, NSDictionary *savedMetaData, NSError * error) {

if (success) {

//image was saved successfully 

}else {

//image was not save. handle error gracefully
}
}];
}
```
`

Provide an image to save, (and you can also pass a metaData NSDictionary that will be saved with the image and returned on completion). Cache manager will do the following:

1. Call the abstract method [willSaveImageWithRequest...] on your subclassed ImageRequest. That gives you a chance to upload the image to server or process it anyway you like. Note that you must return a unique file_id in the completion block. 

2. When receiving the file_id the cache manager will insert the image to the realm persistent cache and the memory cache, and will call its completion block once done.



## Requirements

## Installation

NBImageCache is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "NBImageCache"
```
`

## Author

Noam Bar-on, bar.on.noam1@gmail.com

## License

NBImageCache is available under the MIT license. See the LICENSE file for more info.
<!--=======-->
<!--Fast and asynchronous image cache, based on Realm.io and with a simple block based api-->
