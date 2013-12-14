//
//  ShareManager.m
//  DianDianEr
//
//  Created by Duger on 13-10-28.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "ShareManager.h"
#import "Singleton.h"
#import "lame.h"
#import "ShareViewController.h"
#import "FirstViewController.h"

@implementation ShareManager
{
    NSInteger bodyLength;
    NSMutableData *mutableData;
    CGFloat   _sampleRate;
    
    CompletionBlock _completionBlock;
}
static ShareManager *s_shareMangager = nil;
+(ShareManager *)defaultManager
{
    @synchronized(self)
    {
        if (s_shareMangager == nil) {
            s_shareMangager = [[ShareManager alloc]init];
            
        }
        
    }
    return s_shareMangager;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self cleanShare];
    }
    return self;
}

-(void)toMp3
{
//    NSString *cafFilePath =[NSTemporaryDirectory() stringByAppendingString:@"RecordedFile"];
    NSString *cafFilePath = [[NSBundle mainBundle] pathForResource:@"2013-10-31 13:20:41 +0000" ofType:@"aac"];    
    NSString *mp3FileName = @"Mp3File";
    mp3FileName = [mp3FileName stringByAppendingString:@".mp3"];
    NSString *mp3FilePath = [[NSHomeDirectory() stringByAppendingFormat:@"/Documents/"] stringByAppendingPathComponent:mp3FileName];
    NSLog(@"艾米披散%@",mp3FilePath);
    @try {
        int read, write;
        
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 44100.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        [self performSelectorOnMainThread:@selector(convertMp3Finish)
                               withObject:nil
                            waitUntilDone:YES];
    }
}

-(void)convertMp3Finish
{
    
}



-(void)uploadWithCompletionBlock:(CompletionBlock) completion
{
    if ([Singleton instance].isUploading) {
        return;
    }
    _completionBlock = completion;
    [Singleton instance].isUploading = ![Singleton instance].isUploading;

    self.inPutImagePath = [ShareManager defaultManager].tempImagePath;
#define kManagerUpload_URL @"http://124.205.147.26/student/class_10/team_seven/share/uploadImages.php"
    NSURL *url = [NSURL URLWithString:kManagerUpload_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    NSData *imageData = [[NSData alloc] initWithContentsOfFile:self.inPutImagePath];
    NSData *soundData = [[NSData alloc]initWithContentsOfFile:self.inPutSoundsPath];

    NSString *uid = [[NSUserDefaults standardUserDefaults]objectForKey:kXMPPmyJID];
    NSString *content = [ShareManager defaultManager].shareContents;
    NSString *locationName = [ShareManager defaultManager].locationPlace;
    NSLog(@"内容内容内容%@",content);
    double longitude = self.latitude;
    double latitude = self.longitude;
    NSString *jsonContent = [NSString stringWithFormat:@"{\"uID\":\"%@\",\"shareContent\":\"%@\",\"shareLocationName\":\"%@\",\"longitude\":%f,\"latitude\":%f}",uid,content,locationName,longitude,latitude];

    
    //我是分割线
    NSString *boundary = @"--------mutipart---------upload-----";
    //文件格式
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    //上传日期
    NSDate *date = [NSDate date];
    NSString *content_Disposition1;
    if ([self.inPutImagePath isEqualToString:@""]) {
        content_Disposition1 = [NSString stringWithFormat:@"Content-Disposition: attachment; name=\"imagefile\"\r\n"];
    }else{
        
        content_Disposition1 = [NSString stringWithFormat:@"Content-Disposition: attachment; name=\"imagefile\"; filename=\"%d.png\"\r\n",(int)[date timeIntervalSince1970]];
    }
    NSString *content_Disposition2;
    if ([self.inPutSoundsPath isEqualToString:@""]) {
        content_Disposition2 = [NSString stringWithFormat:@"Content-Disposition: attachment; name=\"musicfile\"\r\n"];
    }else{
    content_Disposition2 = [NSString stringWithFormat:@"Content-Disposition: attachment; name=\"musicfile\"; filename=\"%d.mp3\"\r\n",(int)[date timeIntervalSince1970] + 2];
    }
    
    NSString *content_Disposition3 = [NSString stringWithFormat:@"Content-Disposition: text/html; name=\"jsonContent\"\r\n"];

       
    //发送body内的内容类型
    NSString *content_Type = @"Content-Type: application/octet-stream\r\n\r\n";
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",   boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[content_Disposition3 dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[content_Type dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[jsonContent dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",   boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[content_Disposition1 dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[content_Type dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:imageData];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[content_Disposition2 dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[content_Type dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:soundData];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];
    
    NSLog(@"%@",[[NSString alloc] initWithBytes:body.bytes length:body.length encoding:NSUTF8StringEncoding]);
    
    bodyLength = body.length;
    //异步实现上传文件
    [NSURLConnection connectionWithRequest:request delegate:self];

}

#pragma mark - NSURL connectionDelegate

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{

    mutableData = [[NSMutableData alloc] init];
    return request;
}

//获取发送的进度
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    CGFloat progress = (CGFloat)totalBytesWritten / bodyLength;
    
    [self.delegate changeUploadProgress:(CGFloat)progress];

}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [mutableData appendData:data];
}

//上传成功
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    [self.delegate changeUploadProgress:1.0f];
    [self.delegate setProgress:1.0f];
    NSString *content = [[NSString alloc] initWithData:mutableData encoding:NSUTF8StringEncoding];
    [Singleton instance].url = content;
    NSLog(@"%@",content);
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"分享" message:@"分享成功！" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [alertView show];
    
    [self cleanShare];
    [Singleton instance].isUploading = ![Singleton instance].isUploading;
    
    //下载...
    [[SelectManager defaultManager] downloadRecentShare];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        NSLog(@"lalalalla");
        _completionBlock();
    }
}
-(void)cleanShare
{
    self.inPutImagePath = @"";
    self.tempImagePath = @"";
    self.shareContents = @"";
    self.inPutSoundsPath = @"";
    self.locationPlace = @"";
    
}

@end
