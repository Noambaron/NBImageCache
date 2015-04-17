//
//  NBImageCacheFile.h
//  Noam Bar-on
//
//  Created by Noam Bar-on on 4/2/15.
//  Copyright (c) 2015 Noam Bar-on.
//  Released under an MIT license: http://opensource.org/licenses/MIT
//
#import <UIKit/UIKit.h>
#import <Realm/Realm.h>

/**
 *  this is the data model for the realm persistant object
 */
@interface NBImageCacheFile : RLMObject

/**
 *  class helper method to generate a simple NSString unique identifier from the given file_id and size
 *
 *  @param file_id user defined image file (cached object) identifier
 *  @param size    size of the image
 *
 *  @return  a simple NSString unique identifier used to identify persisted objects
 */
+(NSString *) keyForFileId:(long)file_id size:(CGSize)size;

/**
 *  simple NSString unique identifier used to identify persisted objects
 */
@property NSString * objectId;

/**
 *  a user defined image file (cached object) identifier
 */
@property long file_id;

/**
 *  the width of the image
 */
@property float width;

/**
 *  the hieght of the image
 */
@property float height;

/**
 *  nsdata representation of the UIImage object
 */
@property NSData * imageData;

/**
 *  nsdata representation of the NSDictionary metaData object
 */
@property NSData * metaData;
@end

// This protocol enables typed collections. i.e.:
// RLMArray<NBIamgeCacheFile>
RLM_ARRAY_TYPE(NBIamgeCacheFile)
