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


## Example App 

To run the example project, clone the repo, and run `pod install` from the Example directory first.
You will also need to insert a FlickerAPIFey in the predefined macro on FlickrAPIKey.h
A free FlickrAPIKey is available [here](http://www.flickr.com/services/api/misc.api_keys.html)

## Installation

NBImageCache is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```objective-c
pod "NBImageCache"
```

## Configuring the Image Cache

No special configuration is needed for the cache manager. Only thing you need to do is register the name of the NBImageRequest subclass you will be using.
```objective-c
[[NBImageCache sharedManager] setImageRequestClass:[YourNBImageRequestSubClass class]];
```

## Subclassing NBImageRequest

NBImageRequest is an abstract object that is used as a vehicle for all image processing. Note that the Image is an entity that is uniquely identified by both a file_id AND a size in the image cache. You must subclass NBImageRequest and implement these two imageRequest lifeCycle abstract methods:

```objective-c
//in your MYNBImageRequest.h
#import "NBImageRequest.h"

@interface MYNBImageRequest : NBImageRequest

-(void) imageRequest:(NBImageRequest *)request isAskingForImageWithFileId:(long)file_id withCompletion:(void (^)(long file_id, UIImage * returnedImage))completionBlock;

-(void) willSaveImageWithRequest:(NBImageRequest *)request withCompletion:(void (^)(long file_id, NSError * error))completionBlock;

@end
```

```objective-c
//in your MYNBImageRequest.m

-(void) imageRequest:(NBImageRequest *)request isAskingForImageWithFileId:(long)file_id withCompletion:(void (^)(long file_id, UIImage * returnedImage))completionBlock {
    
    //do what ever you need to get the image. then call:

    completionBlock(file_id, image);    

}
```

This is a mandatory abstract method. Add here the code for any network activity to get the image for the given file id. this method will only be called once for every file id and size, because once it retrieves an image from server, the image will be cached in memory and on disk.

```objective-c
-(void) willSaveImageWithRequest:(NBImageRequest *)request withCompletion:(void (^)(long file_id, NSError * error))completionBlock {    

    //add here any code you need to run before image is saved in cache. must call completion block and return a file_id 

    completionBlock(file_id, nil);

}
```


This is a mandatory abstract method. Add here any processing you need to execute before intire save operation is complete. for example use this to compress the image and send it to the server to get back any metadata about it (like an id maybe..). you can also adjust the metadata object and the image, any changes to the request, image or metadata will be saved. Once done, you must call the completion block and include a file id.

## Providing Source Images to NBImageCache

Normally there is no need to manually save images, as any image downloaded through the cache manager will be automatically saved. But if you need to manually insert an image you can do the following:
```objective-c
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


Provide an image to save, (and you can also pass a metaData NSDictionary that will be saved with the image and returned on completion). Cache manager will do the following:

1. Call the abstract method [willSaveImageWithRequest...] on your subclassed ImageRequest. That gives you a chance to upload the image to server or process it anyway you like. Note that you must return a unique file_id in the completion block. 

2. When receiving the file_id the cache manager will insert the image to the realm persistent cache and the memory cache, and will call its completion block once done.

##Retrieving Images From NBImageCache

The cache manager never returns a UIImage directly. The requested image is included in the completion block. The return value will indicate whether or not the image already exists in the image cache. This is an asynchronous method but if the requested image already exists in the cache, the completion block will be called immediately:

```objective-c
-(void) getImageWithSize:(CGSize)size  fileId:(long)file_id metaData:metaData {

    BOOL imageExists = [[NBImageCache sharedManager] getImageWithSize:size fileId:file_id metaData:metaData withCompletion:^(UIImage *image, long file_id) {

        if (image) {

            [self.imageView setImage:image];
        }
    }];

    if (imageExists == NO) {

        [self.imageView setImage:placeHolderImage;
    }
}
```
Provide a size, and a file id (and you can also pass metaData object that will be returned on completion) and the cache manager will do the following:
1. Look for the image in memory cache and return it through the completion block immediately if found. Return YES as the method return value
2. If not in memory it will look for the image in realm dataase and return it through the completion block immediately if found. Return YES as the method return value
3. If not on either the method will return NO immediately and also call asynchronously your subclass of NBImageRequest [request isAskingForImageWithFileId...]. When that returns, perhaps some time later, the completion block will be called with the image.

## Check if an Image is Available in NBImageCache

NBImageCache will check in memory cache and also persistent cache and will return a boolean indicating whether image is available. This does not run any network activity. only checks inside cache

```objective-c
BOOL imageExists = [[NBImageCache sharedManager] hasImageForFileId:file_id size:size];
```

## Removing Images From NBImageCache

To remove an image from the cache provide a file_id and size (in order to uniquely identify the image file, and check for the completion block for success:

```objective-c
-(void) removeImageWithSize:(CGSize)size  fileId:(long)file_id {

    [[NBImageCache sharedManager] removeImageWithSize:size fileId:file_id withCompletion:^(BOOL success
, long file_id) {

        if (success) {

            //image was deleted successfully;
        }
    }];
}
```

## Clearing memory cache

if needed, mainly when receiving a memory warning, its recommended to clear the memory cache. Note that this will only free the images from memory and they will all persist and be available on the (high performance) realm database, so performance should not be reduced.

```objective-c
 [[NBImageCache sharedManager] freeMemoryCache];
```

## Other Considerations
* Images are saved as png representation NSData objects
* You must have Realm.io integrated in roder to use NBImageCache
* NBImageCache uses the default realm to save images.


## Author

Noam Bar-on, bar.on.noam1@gmail.com

## License

The MIT License (MIT)

Copyright (c) 2014 Noam Bar-on.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

<!--=======-->
<!--Fast and asynchronous image cache, based on Realm.io and with a simple block based api-->
