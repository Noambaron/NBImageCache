//
//  NBImageCacheFile.m
//  Noam Bar-on
//
//  Created by Noam Bar-on on 4/2/15.
//  Copyright (c) 2015 Noam Bar-on.
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "NBImageCacheFile.h"

@implementation NBImageCacheFile

// Specify default values for properties
+ (NSDictionary *)defaultPropertyValues {
    
    NSData * emptyImageData = [NSData new];
    NSData * emptyMetaData = [NSData new];
    
    return @{@"imageData": emptyImageData, @"metaData":emptyMetaData, @"file_id":@(0),@"height":@(0), @"width":@(0)};
}




+ (NSString *) primaryKey {
    return @"objectId";
}

+(NSString *) keyForFileId:(long)file_id size:(CGSize)size {
    
    NSString * key = [[NSString alloc]initWithFormat:@"%li_%f%f",file_id,size.width,size.height];
    return key;
}


@end






