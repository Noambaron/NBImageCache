//
//  MyImageRequest.m
//  NBImageCacheExample
//
//  Created by Noam Bar-on on 4/16/15.
//  Copyright (c) 2015 Noams. All rights reserved.
//

#import "MyImageRequest.h"
#import "FlickrFetcher.h"

@implementation MyImageRequest


-(void) willSaveImageWithRequest:(NBImageRequest *)request withCompletion:(void (^)(long file_id, NSError * error))completionBlock {
    
    long file_id = 0;
    
    completionBlock(file_id, nil);
}


-(void) imageRequest:(NBImageRequest *)request isAskingForImageWithFileId:(long)file_id withCompletion:(void (^)(long file_id, UIImage * returnedImage))completionBlock {
    
    NSDictionary * photo = request.metaData;
    
    NSURL * imageUrl = [FlickrFetcher URLforPhoto:photo format:FlickrPhotoFormatLarge];
    
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:imageUrl];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:urlRequest
                                                    completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
                                                        if (!error) {
                                                            if ([urlRequest.URL isEqual:imageUrl]) {
                                                                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:localFile]];
                                                                
                                                                completionBlock(file_id, image);
                                                            }
                                                        }
                                                    }];
    [task resume];    
}

@end
