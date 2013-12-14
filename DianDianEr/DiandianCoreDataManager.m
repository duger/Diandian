//
//  DiandianCoreDataManager.m
//  DianDianEr
//
//  Created by 信徒 on 13-10-30.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "DiandianCoreDataManager.h"

@interface DiandianCoreDataManager ()

-(NSManagedObjectContext *)context;
-(NSPersistentStoreCoordinator *)coordinator;
-(NSManagedObjectModel *)modle;

@end

static DiandianCoreDataManager *aDiandianCoreDataManager = nil;
@implementation DiandianCoreDataManager
{
    NSManagedObjectContext                  *context;
    NSPersistentStoreCoordinator            *coordinator;
    NSManagedObjectModel                    *model;
    
}

@synthesize delegate;
@synthesize aShare;

+(DiandianCoreDataManager *)shareDiandianCoreDataManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (aDiandianCoreDataManager == nil){
            aDiandianCoreDataManager = [[DiandianCoreDataManager alloc] init];
        }
       
    });
     return aDiandianCoreDataManager;
}
- (id)init
{
    self = [super init];
    if (self) {
        [self context];
    }
    return self;
}



-(NSString *)getPath
{
    NSString * documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString * filePath = [documentPath stringByAppendingFormat:@"/Share.sqlite"];
    return filePath;
}
#pragma mark - 管理器 - 连接器 - 模型器
-(NSManagedObjectContext *)context
{
    if (context != nil ) {
        return context;
    }
    context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [context setPersistentStoreCoordinator:[self coordinator]];
    return context;
}

-(NSPersistentStoreCoordinator *)coordinator
{
    if (coordinator != nil ) {
        return coordinator;
    }
    coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self modle]];
   
    
    NSURL *url = [NSURL fileURLWithPath:[self getPath]];
    
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    [options setValue:@(YES) forKey:NSAddedPersistentStoresKey];
    NSError * error = nil;
    
    [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:options error:&error];
    if (error) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"数据库连接失败" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Back", nil];
        NSLog(@"数据库连接失败");
    }
    return coordinator;
}

-(NSManagedObjectModel *)modle
{
    if (model != nil ) {
        return model;
    }
    model = [NSManagedObjectModel mergedModelFromBundles:nil];
    return model;
}


#pragma 分享
- (void)save
{
    if ([[self context] hasChanges]) {
        [[self context] save:nil];
    }
}
- (Share *)create_a_share
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Share" inManagedObjectContext:[self context]];
     aShare = [[Share alloc] initWithEntity:entity insertIntoManagedObjectContext:[self context]];
    [self.delegate parameterShare:aShare];
    [self save];
    return aShare;
    
}

- (NSArray *)all_share
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Share"];
    NSArray * result = [[self context] executeFetchRequest:fetchRequest error:nil];
    return result;
    
}

-(NSArray *)myShare
{
	NSMutableArray *myShare = [[NSMutableArray alloc]init];
    NSArray *allShare = [[NSArray alloc]initWithArray:[self all_share]];
    for (Share *item in allShare) {
        if ([item.s_user_id isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:kXMPPmyJID]]) {
            [myShare addObject: item];
        }
    }
    return myShare;
}
-(NSArray *)imageShare
{
    NSMutableArray *imageArray = [[NSMutableArray alloc]init];
    NSArray *allShare = [[NSArray alloc]initWithArray:[self all_share]];
    for (Share *item in allShare) {
        if (![item.s_image_url isEqualToString:@"http://124.205.147.26/student/class_10/team_seven/resource/images"]) {
            [imageArray addObject:item];
        }
    }
    return imageArray;
}
-(NSArray *)soundShare
{
    NSMutableArray *soundShare = [[NSMutableArray alloc]init];
    NSArray *allShare = [[NSArray alloc]initWithArray:[self all_share]];
    for (Share *item in allShare) {
        if (![item.s_sound_url isEqualToString:@"http://124.205.147.26/student/class_10/team_seven/resource/sounds"]) {
            [soundShare addObject:item];
        }
    }
    return soundShare;
}
-(NSArray *)textShare
{
    NSMutableArray *textShare = [[NSMutableArray alloc]init];
    NSArray *allShare = [[NSArray alloc]initWithArray:[self all_share]];
    for (Share *item in allShare) {
        if (![item.s_content isEqualToString:@""]) {
            [textShare addObject:item];
        }
    }
    return textShare;
}
- (void)insert_a_share:(NSManagedObject *)object
{
    [[self context] insertObject:object];
    [self save];
}
- (void)delete_a_share:(NSManagedObject *)object
{    
    [[self context] deleteObject:object];
    [self save];
}

#pragma 语音
- (void)isYuyin:(SubShare *)subShare
{
    [delegate parameterYuYin:subShare];
    [self save];
}
#pragma 评论 
- (void)add_a_pingLun:(PingLun *)pingLun
{
    [delegate parameterAdd_a_pingLun:pingLun];
    [self save];
}

- (void)delete_a_pingLun:(PingLun *)pingLun
{
    [delegate parameterDelete_a_pingLun:pingLun];
    [self save];
}
#pragma 转发
- (void)add_a_zhuangFa:(SubShare *)subShare;
{
    [delegate parameterAdd_a_zhuangFa:subShare];
    [self save];
}

- (void)delete_a_zhuangFa:(SubShare *)subShare;
{
    [delegate parameterDelete_a_zhuangFa:subShare];
    [self save];
}

#pragma  赞
- (void)add_a_zan:(SubShare *)subShare;
{
    [delegate parameterAdd_a_zan:subShare];
    [self save];
}
- (void)cancel_a_zan:(SubShare *)subShare;
{
    [delegate parameterCancel_a_zan:subShare];
    [self save];
}

#pragma mark - private methods
-(NSArray *)_allShareID
{
    NSMutableArray *allIDArr = [[NSMutableArray alloc]init];
    NSArray *resultArr = [[NSArray alloc]initWithArray:[self all_share]];
    for (Share *item in resultArr) {
        [allIDArr addObject:[NSNumber numberWithInt:item.s_id]];
    }
    return allIDArr;
    
}

//格式化时间输出样式
static inline NSString * dateFormatter(NSDate *aDate)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *str =  [dateFormatter stringFromDate:aDate];
    return str;
}


@end
