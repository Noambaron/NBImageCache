//
//  ImageViewController.h
//  NBImageCacheExample
//
//  Created by Noam Bar-on on 4/15/15.
//  Copyright (c) 2015 Noams. All rights reserved.
//

#import "ImageViewController.h"
#import "NBImageCache.h"
#import "FlickrFetcher.h"

@interface ImageViewController () <UIScrollViewDelegate, UISplitViewControllerDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation ImageViewController

- (void)setScrollView:(UIScrollView *)scrollView
{
    _scrollView = scrollView;
    _scrollView.minimumZoomScale = 0.2;
    _scrollView.maximumZoomScale = 2.0;
    _scrollView.delegate = self;
    _scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)setPhoto:(NSDictionary *)photo
{
    _photo = photo;
//    self.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
    [self retreieveImage];
}

- (void)retreieveImage
{
    self.image = nil;
    if (self.photo) {
        [self.spinner startAnimating];
        
        NSString * photoId = self.photo[FLICKR_PHOTO_ID];
        
        long file_id = [photoId longLongValue];
        
        [[NBImageCache sharedManager] getImageWithSize:[NBImageCache sharedManager].imageSizeLarge fileId:file_id metaData:self.photo withCompletion:^(UIImage *image, long file_id) {
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.image = image;
            });
            
        }];
    }
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

- (UIImage *)image
{
    return self.imageView.image;
}

- (void)setImage:(UIImage *)image
{
    self.scrollView.zoomScale = 1.0;
    self.imageView.image = image;
    [self.imageView sizeToFit];
    self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
    [self.spinner stopAnimating];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
}












@end
