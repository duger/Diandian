//
//  SelectManager.m
//  DianDianEr
//
//  Created by Duger on 13-10-30.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "SelectManager.h"


#define kRecentShare @"http://124.205.147.26/student/class_10/team_seven/download/downloadRece.php"

@implementation SelectManager
{
    NSMutableData *mutableData;
    NSNumber *fileWeight;
    CGFloat processs;
    NSMutableDictionary *dic;
}

static SelectManager *s_selectManager = nil;
+(SelectManager*)defaultManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (s_selectManager == nil) {
            s_selectManager = [[self alloc]init];
        }
    });
    return s_selectManager;
}
//格式化时间输出样式
static inline NSString * dateFormatter(NSDate *aDate)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *str =  [dateFormatter stringFromDate:aDate];
    return str;
}
-(void)downloadRecentShare
{
    NSURL *url = [NSURL URLWithString:kRecentShare];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [NSURLConnection connectionWithRequest:request delegate:self];
    
     dic = [[NSMutableDictionary alloc] init];
}


#pragma mark - NSURLConnectionDelegate

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{

    mutableData = [[NSMutableData alloc] init];
    return request;
}

//获取发送的进度
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    processs = (CGFloat)totalBytesWritten / [fileWeight integerValue];
    
    [self.delegate changedownProgress:(CGFloat)processs];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"收到反应");
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    fileWeight = [[httpResponse allHeaderFields]objectForKey:@"Content-Length"];
    NSLog(@"字典里有啥呢%@",[[httpResponse allHeaderFields]description]);
    mutableData = [[NSMutableData alloc]init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [mutableData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    processs = 1.0f;
    NSError *error = nil;
    
    NSString *content = [[NSString alloc]initWithData:mutableData encoding:NSUTF8StringEncoding];
//    NSLog(@"杰森杰森杰森%@",content);
    NSMutableArray *tempDate = [NSJSONSerialization JSONObjectWithData:mutableData options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"从网络获取数据失败" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
        [alertView show];
    }
    for (dic in tempDate) {
        //        NSLog(@"%@",dic);
        [[DiandianCoreDataManager shareDiandianCoreDataManager] setDelegate:self];
        NSArray *allID = [[DiandianCoreDataManager shareDiandianCoreDataManager] _allShareID];
        NSLog(@"%@",allID);
        NSLog(@"艾迪%@",[dic objectForKey:@"share_user_id"]);
        NSLog(@"%@", [NSNumber numberWithInt:[[dic objectForKey:@"share_id"]integerValue]]);
        if (![allID containsObject:[NSNumber numberWithInt:[[dic objectForKey:@"share_id"]integerValue]]]) {
            [[DiandianCoreDataManager shareDiandianCoreDataManager] create_a_share];
        }
    }
    
}
#pragma DiandianCoreDataManagerDelegate方法
- (void)parameterShare:(Share *)share
{
    Share *creatShare = [[DiandianCoreDataManager shareDiandianCoreDataManager] aShare];
    creatShare.s_id = [[dic objectForKey:@"share_id"] intValue];
    creatShare.s_user_id = [dic objectForKey:@"share_user_id"];
    creatShare.s_longitude = [[dic objectForKey:@"share_longitude"] doubleValue];

    creatShare.s_createdate = [dic objectForKey:@"share_createdate"];
    creatShare.s_content = [dic objectForKey:@"share_content"] ;
    creatShare.s_sound_url = [dic objectForKey:@"share_sound_url"];
    creatShare.s_image_url= [dic objectForKey:@"share_image_url"];
    creatShare.s_latitude = [[dic objectForKey:@"share_latitude"] doubleValue];
    creatShare.s_locationName = [dic objectForKey:@"share_locationName"];
}
@end
