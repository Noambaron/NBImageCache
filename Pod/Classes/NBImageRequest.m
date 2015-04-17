//
//  NBImageRequest.m
//  Noam Bar-on
//
//  Created by Noam Bar-on on 4/2/15.
//  Copyright (c) 2015 Noam Bar-on.
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "NBImageRequest.h"

@interface NBImageRequest()
@property (strong, nonatomic) NBImageCacheFile * file;
@end


@implementation NBImageRequest

-(instancetype) initWithImage:(UIImage *)image metaData:(NSDictionary *)metaData {
    
    self = [super init];
    if (self) {
        
        if (image) {
            
            [self setImage:image];
        }
        [self setMetaData:metaData];
        
    }
    return self;
}

//====================================================================================================//
//========================================= Save Iamge ===============================================//
//====================================================================================================//

-(void) saveAndSendImageWithCompletion:(void (^)(NBImageRequest * fulfilledRequest, NSError * error))completionBlock {
    
    __block NBImageRequest * weakSelf = self;

    [self willSaveImageWithRequest:self withCompletion:^(long file_id, NSError * error) {
        
        if (file_id) {
            
            NBImageCacheFile * file = [[NBImageCacheFile alloc]init];
            [file setWidth:weakSelf.size.width];
            [file setHeight:weakSelf.size.height];
            [file setFile_id:file_id];
            if (weakSelf.metaData) file.metaData = [NSKeyedArchiver archivedDataWithRootObject:weakSelf.metaData];
            file.imageData = UIImagePNGRepresentation(weakSelf.image);
            [weakSelf setFile_id:file_id];
            [file setObjectId:[NBImageCacheFile keyForFileId:weakSelf.file_id size:weakSelf.size]];

            [weakSelf setFile:file];
            
            //save
            __block NBImageRequest * secondWeakSelf = weakSelf;
            [weakSelf addOrUpdateFile:weakSelf.file withCompletion:^(NBImageCacheFile *finalFile) {
                
                if (finalFile) {
                    NSDictionary * metaData = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:finalFile.metaData];
                    [secondWeakSelf setMetaData:metaData];
                    completionBlock (secondWeakSelf, nil);
                } else {
                    NSLog(@"%s NBImageCache: unknown error occured while tring to save file", __PRETTY_FUNCTION__);
                    completionBlock (secondWeakSelf, nil);
                }
            }];
            
        } else {
            NSLog(@"%s NBImageCache: No File-Id found. make sure you implement the abstract 'willSaveImageWithRequest' method on your subclass of NBImageRequest object, and provide a file_id that is larger than 0", __PRETTY_FUNCTION__);
            completionBlock (weakSelf, error);
        }
    }];
}

-(void) willSaveImageWithRequest:(NBImageRequest *)request withCompletion:(void (^)(long file_id, NSError * error))completionBlock {
    
}


        
-(void) addOrUpdateFile:(NBImageCacheFile *)file withCompletion:(void (^)(NBImageCacheFile * file))completionBlock {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    [realm beginWriteTransaction];
    
    if (self.file_id > 0) [file setFile_id:self.file_id];
    [realm addOrUpdateObject:file];
    
    [realm commitWriteTransaction];
    
    NBImageCacheFile * savedFile = [NBImageCacheFile objectForPrimaryKey:file.objectId];
    completionBlock(savedFile);
}

//====================================================================================================//
//====================================== Retreive Image ==============================================//
//====================================================================================================//


-(BOOL) retreiveImageForFileId:(long)file_id size:(CGSize)size withCompletion:(void (^)(NBImageRequest * request, UIImage *image))completionBlock {
    
    BOOL imageExists = NO;
    
    [self setSize:size];
    [self setFile_id:file_id];
    
    NBImageCacheFile * file = [NBImageCacheFile objectForPrimaryKey:[NBImageCacheFile keyForFileId:file_id size:size]];
    
    if ([file.imageData length] > 0) { //file image exists. retun it
        
        UIImage * retreivedImage = [UIImage imageWithData:file.imageData];
        imageExists = YES;
        completionBlock (self, retreivedImage);
        
    }else { //file does not exists. get it from server
        
        imageExists = NO;
        
//        __block NBImageRequest * weakSelf = self;
        
        //ask for the image using an abstract block
        [self imageRequest:self isAskingForImageWithFileId:file_id withCompletion:^(long file_id, UIImage *returnedImage) {
            
            if (returnedImage) {
                
                //success
                //save the new image
                [self setImage:returnedImage];
                [self saveWithCompletion:^(NBImageRequest *fulfilledRequest) {
                    
                    //we are done.
                    if (completionBlock) {
                        
                        completionBlock(self, returnedImage);
                    }

                }];
                
                
            }else { //handle error
                completionBlock(self, nil);
                NSLog(@"%s isAskingForImageWithFileId:%li falied", __PRETTY_FUNCTION__, file_id);
                
            }
        }];
    }
    return imageExists;
}


-(void) imageRequest:(NBImageRequest *)request isAskingForImageWithFileId:(long)file_id withCompletion:(void (^)(long file_id, UIImage * returnedImage))completionBlock {
        
}


-(void) saveWithCompletion:(void (^)(NBImageRequest *fulfilledRequest))completionBlock {
    
    NBImageCacheFile * file = [[NBImageCacheFile alloc]init];
    [file setObjectId:[NBImageCacheFile keyForFileId:self.file_id size:self.size]];
    [file setWidth:self.size.width];
    [file setHeight:self.size.height];

    if (self.metaData) file.metaData = [NSKeyedArchiver archivedDataWithRootObject:self.metaData];
    
    file.imageData = UIImagePNGRepresentation(self.image);
    
    [self setFile:file];
    
    __weak NBImageRequest * weakSelf = self;
    
    [self addOrUpdateFile:file withCompletion:^(NBImageCacheFile *savedFile) {
        
        if (savedFile) {
            
            completionBlock(weakSelf);
            
        }else {
            NSLog(@"%s NBImageCache: Error occured when performing final file save", __PRETTY_FUNCTION__);
            completionBlock (nil);
        }
    }];
}

//====================================================================================================//
//======================================= Remove Image ===============================================//
//====================================================================================================//



-(void) removeFile:(NBImageCacheFile *)file withCompletion:(void (^)(BOOL success))completionBlock {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    [realm beginWriteTransaction];
    
    if (self.file_id > 0) [realm deleteObject:file];
    
    [realm commitWriteTransaction];
    
    NBImageCacheFile * deletedFile = [NBImageCacheFile objectForPrimaryKey:file.objectId];
    if (!deletedFile) {
        completionBlock(YES);
    }else {
        NSLog(@"%s NBImageCache: Error occured when deleting file. file not delete", __PRETTY_FUNCTION__);

        completionBlock(NO);
    }
}




@end







