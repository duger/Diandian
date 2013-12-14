//
//  DiandianCoreDataManager.h
//  DianDianEr
//
//  Created by 信徒 on 13-10-30.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Share.h"
#import "SubShare.h"
#import "PingLun.h"

@protocol DiandianCoreDataManagerDelegate <NSObject>

@optional
- (void) parameterShare:(Share *)share;
- (void) parameterYuYin:(SubShare *)subShare;
- (void) parameterAdd_a_pingLun:(PingLun *)pingLun;
- (void) parameterDelete_a_pingLun:(PingLun *)pingLun;
- (void) parameterAdd_a_zhuangFa:(SubShare *)subShare;
- (void) parameterDelete_a_zhuangFa:(SubShare *)subShare;
- (void) parameterAdd_a_zan:(SubShare *)subShare;
- (void) parameterCancel_a_zan:(SubShare *)subShare;

@end

@interface DiandianCoreDataManager : NSObject
{
    
}

@property (assign, nonatomic) id<DiandianCoreDataManagerDelegate> delegate;
@property (strong, nonatomic) Share * aShare;


+(DiandianCoreDataManager *)shareDiandianCoreDataManager;
- (id)init;

- (Share *)create_a_share;
- (NSArray *)all_share;
- (void)insert_a_share:(NSManagedObject *)object;
- (void)delete_a_share:(NSManagedObject *)object;


- (void)isYuyin;
- (void)add_a_pingLun;
- (void)delete_a_pingLun;
- (void)add_a_zhuangFa;
- (void)delete_a_zhuangFa;
- (void)add_a_zan;
- (void)cancel_a_zan;


-(NSArray *)_allShareID;
-(NSArray *)myShare;
-(NSArray *)imageShare;
-(NSArray *)soundShare;
-(NSArray *)textShare;
@end



