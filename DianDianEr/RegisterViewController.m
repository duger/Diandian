//
//  RegisterViewController.m
//  DianDianEr
//
//  Created by 王超 on 13-10-18.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "RegisterViewController.h"
#import "LoginViewController.h"
#import "RegisterInfo.h"
#import "RegisterSingleton.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController
@synthesize userName;
@synthesize userPassword;
@synthesize userPassword2;
@synthesize userSex;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[XMPPManager instence] connect];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.topView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"NavBar_meitu_5.png"]];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"注册.png"]];
    [XMPPManager instence].delegate = self;

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
  
#pragma UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([userName resignFirstResponder]||
        [userPassword resignFirstResponder]||
        [userPassword2 resignFirstResponder]||
        [userSex resignFirstResponder]){
        return YES;
    }
    return NO;
}
- (void)viewDidUnload {
    [self setUserName:nil];
    [self setUserPassword:nil];
    [self setUserPassword2:nil];
    [self setUserSex:nil];
    [self setIsUserName:nil];
    [self setTopView:nil];
    [super viewDidUnload];
}
- (IBAction)didClickBack:(id)sender
{
     [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didclickRegister:(UIBarButtonItem *)sender
{
    NSMutableArray * array = [[NSMutableArray alloc] init];
    _isUserName.hidden = YES;

    //所有的register对象
    
    
    NSMutableArray * userInfo = [[NSMutableArray alloc] init];
    for (NSDictionary *dic in array) {
       NSString *tempName = [dic objectForKey:@"Account"];
        if ( [dic objectForKey:@"Account"]) {
              [userInfo addObject:tempName];
        }

    }
        if (userName.text.length < 6) {
            NSLog(@"昵称必须大于6位");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"注册失败"
                                                                                   message:@"昵称必须大于6位！"
                                                                                  delegate:nil
                                                                         cancelButtonTitle:@"Ok"
                                                                         otherButtonTitles:nil];
            [alertView show];
            return;
        }
        if([userInfo containsObject:userName.text] )
        {
            _isUserName.hidden = NO;
            NSLog(@"账号已经被占用");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"注册失败"
                                                                message:@"账号已经被占用！"
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];

            return;
        }
        if(userPassword.text.length < 4)
        {
            NSLog(@"密码必须大于6位");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"注册失败"
                                                                message:@"密码必须大于6位！"
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];
            return;
        }
        if(![userPassword.text isEqualToString: userPassword2.text])
        {
    
            NSLog(@"两次密码不一样");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"注册失败"
                                                                message:@"两次密码不一样！"
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];

            return;
        }
        if (userName.text.length >= 6 && [userPassword.text isEqualToString: userPassword2.text] && userPassword.text.length >= 4)
        {
        
            RegisterInfo * aRegister = [[RegisterSingleton singleton] createdRegister];
            aRegister.aName = userName.text;
            aRegister.aPassword = userPassword.text;
            
            [[XMPPManager instence]registerInSide:userName.text andPassword:userPassword.text];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"注册" message:@"注册中，请等待！" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"好", nil];
//            [alertView show];
//            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        else
        {
            NSLog(@"注册失败");
        }
}

-(void)leaveRegister
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
