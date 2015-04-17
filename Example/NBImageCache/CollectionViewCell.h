//
//  CollectionViewCell.h
//  NBImageCacheExample
//
//  Created by Noam Bar-on on 4/15/15.
//  Copyright (c) 2015 Noams. All rights reserved.
//

#import "ImageView.h"

@interface CollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) NSDictionary * photo;
@property (weak, nonatomic) IBOutlet ImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
