//
//  RegisterSingleton.m
//  DianDianEr
//
//  Created by 信徒 on 13-10-21.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "RegisterSingleton.h"
#import "RegisterInfo.h"
#import  <CoreData/CoreData.h>

@interface RegisterSingleton ()

//为了获取对应数据
- (NSManagedObjectContext *) context;
- (NSManagedObjectModel *)   model;
- (NSPersistentStoreCoordinator *) coordinator;

@end

@implementation RegisterSingleton


{
    //数据管理器
    NSManagedObjectContext       * context;
    //数据连接器
    NSPersistentStoreCoordinator * coordinator;
    //数据模型器
    NSManagedObjectModel         * model;
}
static RegisterSingleton *aRegisterSingleton = nil;
+(RegisterSingleton *)singleton
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (aRegisterSingleton == nil) {
            aRegisterSingleton = [[RegisterSingleton alloc]init];
        }
    });
    return aRegisterSingleton;
}

#pragma mark - 管理器 -连接器 - 模型器
- (NSManagedObjectContext *) context
{
    if (context != nil) {
        return context;
    }
    //实例化管理器
    context = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSMainQueueConcurrencyType];
    //设置管理器对应的连接器
    [context setPersistentStoreCoordinator:self.coordinator];
    return context;
}

- (NSPersistentStoreCoordinator *) coordinator
{
    if (coordinator != nil) {
        return coordinator;
    }
    coordinator = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:[self model]];
    
    //增加数据连接器的存储作用
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
    //获取数据库文件路径
    NSString *sqlitePath = [documentPath stringByAppendingFormat:@"/custom.sqlite"];
    NSURL *url = [NSURL fileURLWithPath:sqlitePath];
    NSError *error = nil;
    
    //添加连接器升级时,使用的设置
    NSMutableDictionary *options = [[NSMutableDictionary alloc]init];
    [options setObject:@(YES) forKey:NSMigratePersistentStoresAutomaticallyOption];
 
    [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:options error:&error];
    return coordinator;
}

- (NSManagedObjectModel *)model
{
    if (model != nil) {
        return model;
    }
    model = [NSManagedObjectModel mergedModelFromBundles:nil];
    return model;
}

#pragma mark - public methods
-(RegisterInfo *)createdRegister
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"RegisterInfo" inManagedObjectContext:[self context]];
    
    RegisterInfo *aRegister= [[RegisterInfo alloc] initWithEntity:entity insertIntoManagedObjectContext:[self context]];
    [self save];
    return aRegister;
  
}
-(void)save
{
    if ([[self context]hasChanges]) {
        [[self context]save:nil];
    }
}
-(NSArray *)allRegister
{

    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"RegisterInfo"];
    
    NSArray *result = [[self context]executeFetchRequest:fetchRequest error:nil];
    
    return result;
}
@end
