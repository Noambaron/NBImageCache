//
//  CollectionViewCell.m
//  NBImageCacheExample
//
//  Created by Noam Bar-on on 4/15/15.
//  Copyright (c) 2015 Noams. All rights reserved.
//

#import "CollectionViewCell.h"
#import "FlickrFetcher.h"
#import "NBImageCache.h"

@implementation CollectionViewCell

- (void)setPhoto:(NSDictionary *)photo
{
    _photo = photo;
    //    self.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
    [self retreieveImage];
}

- (void)retreieveImage
{
    self.imageView.image = nil;
    if (self.photo) {
        [self.activityIndicator startAnimating];
        
        NSString * photoId = self.photo[FLICKR_PHOTO_ID];
        
        long file_id = [photoId longLongValue];
        
        [[NBImageCache sharedManager] getImageWithSize:[NBImageCache sharedManager].imageSizeLarge fileId:file_id metaData:self.photo withCompletion:^(UIImage *image, long file_id) {
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageView.image = image;
                [self.activityIndicator stopAnimating];
            });
            
        }];
    }
}

@end
