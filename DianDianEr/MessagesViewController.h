//
//  MessagesViewController.h
//  DianDianEr
//
//  Created by Duger on 13-10-23.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPFramework.h"

@interface MessagesViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,XMPPRosterDelegate>
@property (retain, nonatomic) IBOutlet UITextField *enterTextField;
- (IBAction)didClickButton:(UIBarButtonItem *)sender;
@property (retain, nonatomic) IBOutlet UITableView *tableView;

//@property (nonatomic, retain) IBOutlet FaceViewController   *phraseViewController;
@property (nonatomic, retain) NSString               *phraseString;
@property (nonatomic, retain) NSString               *titleString;
@property (nonatomic, retain) NSMutableString        *messageString;
@property (nonatomic, retain) NSMutableArray		 *chatArray;

@property (nonatomic, retain) NSDate                 *lastTime;
@property (nonatomic,retain) NSString *toSomeOne;
@property (nonatomic, strong) XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage;    //单例获得
@property (nonatomic, strong) XMPPStream *xmppStream;
@end
