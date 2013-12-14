//
//  Share.h
//  DianDianEr
//
//  Created by Duger on 13-11-5.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SubShare;

@interface Share : NSManagedObject

@property (nonatomic, retain) NSString * s_content;
@property (nonatomic, retain) NSString * s_createdate;
@property (nonatomic) int16_t s_id;
@property (nonatomic, retain) NSString * s_image_url;
@property (nonatomic) double s_latitude;
@property (nonatomic) double s_longitude;
@property (nonatomic, retain) NSString * s_sound_url;
@property (nonatomic, retain) NSString * s_user_id;
@property (nonatomic, retain) NSString * s_locationName;
@property (nonatomic, retain) NSSet *relationship;
@end

@interface Share (CoreDataGeneratedAccessors)

- (void)addRelationshipObject:(SubShare *)value;
- (void)removeRelationshipObject:(SubShare *)value;
- (void)addRelationship:(NSSet *)values;
- (void)removeRelationship:(NSSet *)values;

@end
