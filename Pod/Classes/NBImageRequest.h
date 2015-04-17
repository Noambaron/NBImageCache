//
//  NBImageRequest.h
//  Noam Bar-on
//
//  Created by Noam Bar-on on 4/2/15.
//  Copyright (c) 2015 Noam Bar-on.
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import <Foundation/Foundation.h>
#import "NBImageCacheFile.h"

/**
 * NBImageRequest is an abstract object that is used as a vehicle for all image proccessing.
 * Note that the Image is an entity that is uniquely identified by both a file_id AND a size in the image cache.
 */
@interface NBImageRequest : NSObject


/**
 *  The Image
 */
@property (strong, nonatomic) UIImage * image;
/**
 *  an optional dictionary holding any metaData you might want with your image.
 */
@property (strong ,nonatomic) NSDictionary * metaData;
/**
 *  an internal unique identifier used for realm object persistance.
 */
@property (strong, nonatomic) NSString * object_id;
/**
 *  size of the image that is proccessed.
 */
@property (nonatomic) CGSize size;
/**
 *  file id is an identifer for the image on your remote server. set a file id to an uploaded image, or retrieve an image using this file_id (and the size)
 */
@property (nonatomic) long file_id;


/**
 *  initializer for the imageRequest object. both image and metaData can be nil.
 *
 *  @param image    the image object
 *  @param metaData the optional metaData dictionary
 *
 *  @return returns an instance of the concrete subclass of NBImageRequest or NBImageRequest objcet if no subclass set.
 */
-(instancetype) initWithImage:(UIImage *)image metaData:(NSDictionary *)metaData;

/**
 *  This calls the implemented method [willSaveImageWithRequest...] and save an image in cache after getting file_id.
 *
 *  @param completionBlock this is where you are informed that save procedure was successful (or not). you can access the fulfilledRequest variable's properties to get the image, the metaData and the file_id.
 */
-(void) saveAndSendImageWithCompletion:(void (^)(NBImageRequest * fulfilledRequest, NSError * error))completionBlock;

/**
 *  this retreieves a requested image. It never returns a UIImage directly. The requested image is included in the completion block. The return value will indicate whether or not the image already exists in the image cache. This is a asynchronous method but if the requested image already exists in the image cache, the completion block will be called immediately. 
 *
 *  @param file_id         the unique identifier for the file
 *  @param size            the size of the requested image
 *  @param completionBlock this is where the requested image is received when it is available.
 *
 *  @return A boolean indicating whether or not the image already exists in the image cache
 */
-(BOOL) retreiveImageForFileId:(long)file_id size:(CGSize)size withCompletion:(void (^)(NBImageRequest * request, UIImage *image))completionBlock;


/**
 *  removes a given file from the memory and the persistant realm database
 *
 *  @param file            the relam object to be deleted
 *  @param completionBlock when operation is complete, this returns a boolean indicating whether or not the delete succeeded
 */
-(void) removeFile:(NBImageCacheFile *)file withCompletion:(void (^)(BOOL success))completionBlock;



/**
 *  mandatory abstract method. Add here any processing you need executed after image file is written but before intire save operation is complete. for example use this to compress the image and send it to the server to get back any metadata about it (like an id maybe..). you can also adjust the metadata object and the image, any changes to the request image or metadata will be saved.
 *
 *  @param request         the request object that is incharge of proccessing the request for a specific image and returning it.
 *  @param completionBlock must call this completion block when done to let the request object that it can continue proccessing. you must pass a unique identifier (long)file_id that is grater than 0. if anything goes wrong with this operation you can alwais send back an error object and it will be thrown back when request is fulfilled.
 */
-(void) willSaveImageWithRequest:(NBImageRequest *)request withCompletion:(void (^)(long file_id, NSError * error))completionBlock;



/**
 *  mandatory abstract method. Add here your call to any remote server to get the image for the given file id. this method will only be called once for every file id and size, because once it retrieves an image from server, the image will be cached in memory and in database.
 *
 *  @param request         this is the NBImageRequest object that is processing.
 *  @param file_id         the file id for the image needed
 *  @param completionBlock completion block must be called for operation to continue. it should return the file id and a uiimage if retreived from server or nil of error occured.
 */
-(void) imageRequest:(NBImageRequest *)request isAskingForImageWithFileId:(long)file_id withCompletion:(void (^)(long file_id, UIImage * returnedImage))completionBlock;
@end
