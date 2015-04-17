//
//  MyImageRequest.h
//  NBImageCacheExample
//
//  Created by Noam Bar-on on 4/16/15.
//  Copyright (c) 2015 Noams. All rights reserved.
//

#import "NBImageRequest.h"

@interface MyImageRequest : NBImageRequest


-(void) willSaveImageWithRequest:(NBImageRequest *)request withCompletion:(void (^)(long file_id, NSError * error))completionBlock;

-(void) imageRequest:(NBImageRequest *)request isAskingForImageWithFileId:(long)file_id withCompletion:(void (^)(long file_id, UIImage * returnedImage))completionBlock;

@end
