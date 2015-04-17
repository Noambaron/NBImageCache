//
//  NBImageCache.h
//  Noam Bar-on
//
//  Created by Noam Bar-on on 4/2/15.
//  Copyright (c) 2015 Noam Bar-on.
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/**
 *  This object is a singleton object that coordinates all image NBImageRequest requests.
    NBImageRequest is an abstract object that is used as a vehicle for all image proccessing.
    Note that the Image is an entity that is uniquely identified by both a file_id AND a size in the image cache.
    No need to initialize this object. it is lazyliy initialized
    <ake sure you set the imageRequest class of your NBImageRequest subclass
 
    for your convenience it has imageSize (of type CGSize) properties you can set to your apps most common image sizes. the default values are:
    
    Large = full screen size.
    Medium = (100,100)
    Small = (40,40)
 
 
 */
@interface NBImageCache : NSObject

/**
 *  convenience property for image size. default is full screen size. change it to what ever you need.
 */
@property (nonatomic) CGSize imageSizeLarge;
/**
 *  convenience property for image size. default is 100 x 100. change it to what ever you need.
 */
@property (nonatomic) CGSize imageSizeMedium;
/**
 *  convenience property for image size. default is 40 x 40. change it to what ever you need.
 */
@property (nonatomic) CGSize imageSizeSmall;

/**
 *  This object is a singleton object that coordinates all image requests.
    No need to initialize (alloc init) this object. it is lazyliy initialized
    make sure you set the imageRequest class of your NBImageRequest subclass
 *
 *  @return returns the shared chache object
 */
+ (NBImageCache *) sharedManager;

/**
 *  This is how you let the chache manager know the class of your subclassed imageRequest. if you do not set this you will not have access to any of the "callbacks" of each imageRequest lifecycle (isAskingForImage / willSaveImage / successfullyDeletedImage)
 *
 *  @param className The class of your NBImageRequest subclass ([yourClass class]);
 */
-(void) setImageRequestClass:(Class)className;

/**
 *  checks memory cache and also persistent cache and returns a boolean indicating whether image is available. This does not run any network activity. only checks inside cache
 *
 *  @param file_id the unique identifier you assigned to the image
 *  @param size    the size of the image requested. this will only return YES if the image with the exact size is found.
 *
 *  @return a boolean indicating whether image is available
 */
-(BOOL) hasImageForFileId:(long)file_id size:(CGSize)size;

/**
 *  this is how you request an image. The cache manager never returns a UIImage directly. The requested image is included in the completion block. The return value will indicate whether or not the image already exists in the image cache. This is an asynchronous method but if the requested image already exists in the image cache, the completion block will be called immediately.
    
    Provide a size, and a file id (and you can also pass metaData object that will be returned on completion) and cache manager will do the following:
    look for image in memory cache and retrun it through the completion block immediately if found. Return YES as the methods return value
    if not in memory it will look for the image in realm database and return it through the completion block immediately if found. Return YES as the methods return value
    if not on either the method will return NO immediately and also will call asynchronously your subclass of NBImageRequest [request isAskingForImageWithFileId...]. When that returns, perhaps some time later, the completion block will be called with the image.
 *
 *  @param size            the size of the requested image
 *  @param file_id         the unique identifier for the file
 *  @param metaData        an optional object that you can pass into the asynchronous process of retreiving. you will have a chance to modify it on the [request isAskingForImageWithFileId...] call and you will get it back eventually along side the retreieved image.
 *  @param completionBlock this is where you recieve the requested image when it is available.
 *
 *  @return A boolean indicating whether or not the image already exists in the image cache
 */
-(BOOL) getImageWithSize:(CGSize)size fileId:(long)file_id metaData:(NSDictionary *)metaData withCompletion:(void (^)(UIImage * image, long file_id))completionBlock;


/**
 *  this is how you manually insert image.
 
 Provide an image to save, (and you can also pass metaData object that will be saved with the image and returned on completion) and cache manager will do the following:
    call the abstract method [willSaveImageWithRequest...] on your subclassed ImageRequest. that gives you a chance to upload the image to server or process it anyway you like. Note that you must return a unique file_id in the completion block.
    when receiving the file_id you assigned the cache manager will insert the image to the realm persistent cache and the memory cache
 *
 *  @param image           the image you wish to insert
 *  @param metaData        any metadata you wish to save along side the image
 *  @param completionBlock this is where you are notified that the image was saved successfully.
 */
-(void) saveImage:(UIImage *)image metaData:(NSDictionary *)metaData withCompletion:(void (^)(BOOL success, UIImage * savedImage, NSDictionary * savedMetaData, NSError * error))completionBlock;

/**
 *  this is how you remove an image from the cache.
    provide a file_id and size (in order to uniquely identify the image file, and check for the completion block for success.
 *
 *  @param size            the size of the requested image
 *  @param file_id         the unique identifier for the file
 *  @param completionBlock this is where you are notified that the image was removed successfully.
 */
-(void) removeImageWithSize:(CGSize)size fileId:(long)file_id withCompletion:(void (^)(BOOL success, long file_id))completionBlock;


/**
 *  This is how you free all images stored in memory cache. Note that all images will still be available in the persistant realm database.
 */
-(void)freeMemoryCache;



@end
