//
//  NBImageCache.m
//  Noam Bar-on
//
//  Created by Noam Bar-on on 4/2/15.
//  Copyright (c) 2015 Noam Bar-on.
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "NBImageCache.h"
#import "NBImageCacheFile.h"
#import "NBImageRequest.h"


@interface NBImageCache()

@property (strong, nonatomic) NSMutableDictionary * cachedImages;
@property (strong, nonatomic) dispatch_queue_t access_cachedImages;
@property (strong, nonatomic) Class class;
@end


@implementation NBImageCache


+ (NBImageCache *) sharedManager {
    
    static NBImageCache * singleton = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^ {
        
        singleton = [[NBImageCache alloc] init];
    });
    
    return singleton;
}


- (id)init {
    
    self = [super init];
    if (self != nil) {
        
        _access_cachedImages = dispatch_queue_create("access_cachedImages", DISPATCH_QUEUE_SERIAL);
        _cachedImages = [NSMutableDictionary new];
        
        //setting defaults
        _class = [NBImageRequest class];
        _imageSizeLarge = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        _imageSizeMedium = CGSizeMake(100, 100);
        _imageSizeSmall = CGSizeMake(40, 40);
    }
    return self;
}

-(void) setImageRequestClass:(Class)class {
    
    _class = class;
}

//sirialized access to the cachedImages
-(NSMutableDictionary *) cachedImages {
    
    __block NSMutableDictionary * images;
    
    dispatch_sync(self.access_cachedImages, ^{
        
        images = _cachedImages;
    });
    return images;
}



/**
 *  looks for a specified image with specified size in memory (self.cahchedImages) for the image, and then if not in memory looks on file.
 *
 *  @param file_id a uniqe identifier of the image file in realm database
 *  @param size    the size for the requested image
 *
 *  @return return YES if image is in memory or on disk. NO if image with that size was never chached
 */
-(BOOL) hasImageForFileId:(long)file_id size:(CGSize)size {
    
    NSString * key = [NBImageCacheFile keyForFileId:file_id size:size];
    
    UIImage * requestedImage = self.cachedImages[key];
    
    if (requestedImage) {
        
        return YES;
        
    }else {
        
        NBImageCacheFile * file = [NBImageCacheFile objectForPrimaryKey:key];
        return ([file.imageData length] > 0) ? YES : NO;
    }
}




-(void) saveImage:(UIImage *)image metaData:(NSDictionary *)metaData withCompletion:(void (^)(BOOL success, UIImage * savedImage, NSDictionary * savedMetaData, NSError * error))completionBlock {
    
    id imageRequest = [[[self.class class] alloc]initWithImage:image metaData:metaData];
    [imageRequest setSize:image.size];
    
    [imageRequest saveAndSendImageWithCompletion:^(NBImageRequest *fulfilledRequest, NSError * error) {
        
        if (fulfilledRequest.image) {
            
            [self.cachedImages setObject:fulfilledRequest.image forKey:[NBImageCacheFile keyForFileId:fulfilledRequest.file_id size:fulfilledRequest.image.size]];
            
            completionBlock(YES, fulfilledRequest.image, fulfilledRequest.metaData, nil);
        }else {
            
            completionBlock(NO, nil, nil, error);
        }
    }];
}

-(BOOL) getImageWithSize:(CGSize)size fileId:(long)file_id metaData:(NSDictionary *)metaData withCompletion:(void (^)(UIImage * image, long file_id))completionBlock {
    
    //trying to get the image form memory cache first
    UIImage * requestedImage = self.cachedImages[[NBImageCacheFile keyForFileId:file_id size:size]];
    if (requestedImage) {
        
        completionBlock(requestedImage, file_id);
        return YES;
    }
    
    //retreiving image from disk
    id imageRequest = [[[self.class class] alloc]initWithImage:nil metaData:metaData];
    [imageRequest setFile_id:file_id];
    [imageRequest setSize:size];
    
    BOOL imageExists = [imageRequest retreiveImageForFileId:file_id size:size withCompletion:^(NBImageRequest *request, UIImage *retreievedImage) {
        
        // This completion block may be called much later. We should check...
        if (retreievedImage) {
            
            [self.cachedImages setObject:retreievedImage forKey:[NBImageCacheFile keyForFileId:file_id size:size]];
            
            if (completionBlock) {
                completionBlock(retreievedImage, request.file_id);
            }
            
        }else { //error occured and no image returned
            
            completionBlock (nil, request.file_id);
        }
    }];
    
    return imageExists;
}


-(void) removeImageWithSize:(CGSize)size fileId:(long)file_id withCompletion:(void (^)(BOOL success, long file_id))completionBlock {
    
    NSString * key = [NBImageCacheFile keyForFileId:file_id size:size];
    //trying to get the image form memory cache first
    UIImage * requestedImage = self.cachedImages[key];
    if (requestedImage) {
        
        [self.cachedImages removeObjectForKey:key];
    }
    //now from file
    NBImageCacheFile * file = [NBImageCacheFile objectForPrimaryKey:key];
    
    if (file) {
        
        NBImageRequest * imageRequest = [[NBImageRequest alloc]initWithImage:nil metaData:nil];
        [imageRequest removeFile:file withCompletion:^(BOOL success) {
            
            if (success) {
                completionBlock (YES, file_id);
            }
        }];
    }
}



-(void)dealloc {
    
    self.cachedImages = nil;
}


-(void) freeMemoryCache {
    
    self.cachedImages = [NSMutableDictionary new];
}

@end
