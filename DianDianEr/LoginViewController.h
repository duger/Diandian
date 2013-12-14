//
//  LoginViewController.h
//  DianDianEr
//
//  Created by 王超 on 13-10-18.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController<XMPPManagerDelegate>



@property (strong, nonatomic) IBOutlet UITextField *userName;
@property (strong, nonatomic) IBOutlet UITextField *userPassword;

- (IBAction)didClickRegister:(UIButton *)sender;

- (IBAction)testLogin:(UIButton *)sender;
- (IBAction)didClickLogin:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIButton *registerButton;
@property (strong, nonatomic) IBOutlet UIButton *guestButton;


@end
