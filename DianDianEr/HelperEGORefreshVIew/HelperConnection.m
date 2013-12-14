//
//  HelperConnection.m
//  TuanProject
//
//  Created by 李朝伟 on 13-8-27.
//  Copyright (c) 2013年 lanou. All rights reserved.
//

#import "HelperConnection.h"
#import "ASIFormDataRequest.h"
#import "JSONKit.h"

@implementation HelperConnection
{
    
}
@synthesize httpRequest = _httpRequest;


-(id)initWithTarget : (id) aTarget action:(SEL)action prompted : (BOOL)isPrompted //初始化方法
{
    self = [super init];
    if (self) {
        self.tatget = aTarget;
        _callBackAction = action;
        _prompted = isPrompted;
    }
    return self;
}

//通过传入的url地址,直接返回数据 (get请求方式)
- (void)getUrl : (NSString *)urlStr
{
    NSURL * getUrl = [NSURL URLWithString:urlStr];
    self.httpRequest = [ASIHTTPRequest requestWithURL:getUrl];
    _httpRequest.delegate = self;//设置代理委托
    _httpRequest.timeOutSeconds = 30.0;//超时时间
    _httpRequest.requestMethod = @"GET";//设置网络请求方法
    _httpRequest.validatesSecureCertificate = NO;// ???
    [_httpRequest startAsynchronous];//开始异步获取数据 (自动启用以下代理方法)
}

#pragma mark - ASIHTTPRequestDelegate
//请求开始(是否显示loading 提示)
- (void)requestStarted:(ASIHTTPRequest *)request
{
    if (_prompted) {
        [ASIHTTPRequest showNetworkActivityIndicator];
    }else
    {
        [ASIHTTPRequest hideNetworkActivityIndicator];
    }
}
//request收到响应(获取网络连接 请求状态数据)
- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    _statusCode = request.responseStatusCode;
}
//请求完成 (获取数据)
- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *jsonStr;//接收数据
    BOOL isDataCompress = [request isResponseCompressed];//判断请求数据是否为压缩数据
    if (isDataCompress) {
        NSData *unCompressData= [request responseData];//解压数据
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        jsonStr = [[NSString alloc]initWithData:unCompressData encoding:enc];
    }
    //    else
    //    {
    //        NSLog(@"=====++++++");
    //        jsonStr = request.responseString; //写在此处不执行
    //    }
    
    jsonStr = request.responseString;
    
    //request有两个属性 responseString responseData
    //    NSData *data = request.responseData;
    //    NSString *newStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    //    NSLog(@"newURL = %@",newStr);
    
    [self networkConnectionDidFinishLoading:jsonStr];
    [ASIHTTPRequest hideNetworkActivityIndicator];//隐藏loading
    
    
}
//请求失败时
- (void)requestFailed:(ASIHTTPRequest *)request
{
    _hasError = TRUE; //有错误
    NSLog(@"request error code = %d",request.error.code);
    switch (request.error.code)
    {
        case ASIConnectionFailureErrorType: //连接失败
        {
            if (_prompted)
            {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                 message:@"网络连接断开,请检查网络设置!"
                                                                delegate:nil
                                                       cancelButtonTitle:@"确定"
                                                       otherButtonTitles:nil, nil];
                [alert show];
                [alert release];
            }
        }
            break;
        case ASIRequestTimedOutErrorType: //连接超时
            if (_prompted)
            {
                UIAlertView * alertTimeOut = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                        message:@"连接超时,请重试!"
                                                                       delegate:nil
                                                              cancelButtonTitle:@"确定"
                                                              otherButtonTitles:nil, nil];
                [alertTimeOut show];
                [alertTimeOut release];
            }
            break;
        case ASIAuthenticationErrorType:
        case ASIRequestCancelledErrorType:
        case ASIUnableToCreateRequestErrorType:
        default:
            break;
    }
    
    if (_tatget && [_tatget respondsToSelector:_callBackAction])
    {
        [_tatget performSelector:_callBackAction withObject:self withObject:nil];
    }
    
}

#pragma mark - custom methods
//解析完进行数据处理
//请求完成，把解析的数据回调给调用类
- (void)networkConnectionDidFinishLoading:(NSString *)content
{
    NSLog(@"statusCode === %d",_statusCode);
    switch (_statusCode)
    {
        case 200: // OK
            break;
        case 400: // BadRequest
        case 403: // Forbidden
        case 401: // Not Authorized
        case 404: // Not Found
        case 500: // Internal Server Error
        case 502: // Bad Gateway
        case 503: // Service Unavailable
        default:
        {
            UIAlertView * serverError = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                   message:@"服务器错误!"
                                                                  delegate:nil
                                                         cancelButtonTitle:@"确定"
                                                         otherButtonTitles:nil, nil];
            [serverError show];
            [serverError release];
            
            _hasError = true;
            if (_tatget && [_tatget respondsToSelector:_callBackAction])
            {
                [_tatget performSelector:_callBackAction withObject:self withObject:nil];//有错误时,参数为空,回调
            }
        }
            return;
    }
    
    NSData * jsonData = [content dataUsingEncoding:NSUTF8StringEncoding];
    //    NSLog(@"jsonData dic ====== %@",jsonData);
    NSDictionary * dic = [jsonData objectFromJSONData];
    
    //================================ json解析,返回一个字典
    //    NSDictionary* response_head = [dic objectForKey:@"multiPageResult"]; //这里用时需要进行修改
    //    NSLog(@"Json Content JsonValue dic = %@",dic);
    
    if (_tatget && [_tatget respondsToSelector:_callBackAction])
    {
        [_tatget performSelector:_callBackAction withObject:self withObject:dic];
    }
}

//取消请求
- (void)cancelRequest
{
    [self.httpRequest clearDelegatesAndCancel];
    _hasCancel = YES;
    if (_tatget && [_tatget respondsToSelector:_callBackAction])
    {
        [_tatget performSelector:_callBackAction withObject:self withObject:nil];
    }
}

- (void)dealloc
{
    [self.httpRequest clearDelegatesAndCancel];
    [_httpRequest release];
    [_erroMessage release];
    [super dealloc];
}
@end
