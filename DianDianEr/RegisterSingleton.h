//
//  RegisterSingleton.h
//  DianDianEr
//
//  Created by 信徒 on 13-10-21.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RegisterInfo;
@interface RegisterSingleton : NSObject

+(RegisterSingleton *)singleton;

-(RegisterInfo *)createdRegister;

-(NSArray *)allRegister;
@end
