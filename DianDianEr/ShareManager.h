//
//  ShareManager.h
//  DianDianEr
//
//  Created by Duger on 13-10-28.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol ShareManagerDelegate <NSObject>

-(void)changeUploadProgress:(CGFloat)progress;
- (void)setProgress:(float)progress;

@end

typedef void (^CompletionBlock)();

@interface ShareManager : NSObject<NSURLConnectionDataDelegate>
+(ShareManager *)defaultManager;

@property(nonatomic,assign) id<ShareManagerDelegate> delegate;
@property(nonatomic,retain) UIImage *currentImage;
@property(nonatomic,copy) NSString *inPutSoundsPath;
@property(nonatomic,copy) NSString *shareContents;
@property(nonatomic,assign) double longitude;
@property(nonatomic,assign) double latitude;
@property(nonatomic,copy) NSString *inPutImagePath;
@property(nonatomic,copy) NSString *tempImagePath;
//地点
@property(nonatomic,copy) NSString *locationPlace;

-(void)uploadWithCompletionBlock:(CompletionBlock) completion;

-(void)toMp3;
@end
