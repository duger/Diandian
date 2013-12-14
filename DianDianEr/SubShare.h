//
//  SubShare.h
//  DianDianEr
//
//  Created by 信徒 on 13-11-1.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SubShare : NSManagedObject

@property (nonatomic) int16_t s_yuYin;
@property (nonatomic) int16_t s_zhuangFa;
@property (nonatomic) int16_t s_pingLun;
@property (nonatomic) int16_t s_zang;
@property (nonatomic, retain) NSSet *relationship;
@end


@interface SubShare (CoreDataGeneratedAccessors)

- (void)addRelationshipObject:(NSManagedObject *)value;
- (void)removeRelationshipObject:(NSManagedObject *)value;
- (void)addRelationship:(NSSet *)values;
- (void)removeRelationship:(NSSet *)values;

@end
