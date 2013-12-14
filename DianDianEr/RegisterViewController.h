//
//  RegisterViewController.h
//  DianDianEr
//
//  Created by 王超 on 13-10-18.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterViewController : UIViewController<XMPPManagerDelegate>
@property (strong, nonatomic) IBOutlet UIView *topView;

@property (strong, nonatomic) IBOutlet UITextField *userName;
@property (strong, nonatomic) IBOutlet UITextField *userPassword;
@property (strong, nonatomic) IBOutlet UITextField *userPassword2;
@property (strong, nonatomic) IBOutlet UISegmentedControl *userSex;
@property (strong, nonatomic) IBOutlet UILabel *isUserName;

- (IBAction)didClickBack:(UIBarButtonItem *)sender;

- (IBAction)didclickRegister:(UIBarButtonItem *)sender;

@end
