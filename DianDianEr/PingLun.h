//
//  PingLun.h
//  DianDianEr
//
//  Created by 信徒 on 13-11-1.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PingLun : NSManagedObject

@property (nonatomic) int16_t p_user_id;
@property (nonatomic) double p_longitude;
@property (nonatomic) double p_latitude;
@property (nonatomic) int16_t p_id;
@property (nonatomic, retain) NSString * p_pingLunTime;
@property (nonatomic, retain) NSString * p_content;



@end
