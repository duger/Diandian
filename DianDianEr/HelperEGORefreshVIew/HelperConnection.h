//
//  HelperConnection.h
//  TuanProject
//
//  Created by 李朝伟 on 13-8-27.
//  Copyright (c) 2013年 lanou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
@class ASIHTTPRequest;
@interface HelperConnection : NSObject<ASIHTTPRequestDelegate>
{
    ASIHTTPRequest *_httpRequest;       //ASIRequest
    BOOL _prompted;                     //是否显示 loading 加载提示
    int  _statusCode;                   //请求网络状态
    BOOL _hasError;                      //是否有错
    BOOL _hasCancel;                     //是否取消请求标识
}
@property (nonatomic,retain)ASIHTTPRequest *httpRequest;
@property (nonatomic,assign)id tatget;//回调target
@property (nonatomic,assign)SEL callBackAction;//回调方法
@property (nonatomic,retain)NSString *erroMessage; //回调错误 (可选)
@property (nonatomic,assign)BOOL               hasError;
@property (nonatomic,assign)BOOL               hasCancel;

-(id)initWithTarget : (id) aTarget action:(SEL)action prompted : (BOOL)isPrompted; //初始化方法
- (void)getUrl : (NSString *)urlStr;//请求地址传入接口

- (void)cancelRequest;//取消请求
@end
