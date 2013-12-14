//
//  RegisterInfo.h
//  DianDianEr
//
//  Created by 信徒 on 13-10-22.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RegisterInfo : NSManagedObject

@property (nonatomic) int16_t aAge;
@property (nonatomic, retain) NSString * aName;
@property (nonatomic, retain) NSString * aPassword;
@property (nonatomic, retain) NSData * aPhoto;
@property (nonatomic, retain) NSString * aSex;

@end
