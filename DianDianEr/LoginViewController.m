//
//  LoginViewController.m
//  DianDianEr
//
//  Created by 王超 on 13-10-18.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterInfo.h"
#import "RegisterSingleton.h"
#import "SidebarViewController.h"
#import "RegisterViewController.h"


@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize userName;
@synthesize userPassword;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"logitBackGround.png"]];
    
    [XMPPManager instence].delegate = self;
    [[XMPPManager instence]setupStream];
    /*
     if (![[XMPPManager instence]connect]) {
     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting"
     message:@"See console for error details."
     delegate:nil
     cancelButtonTitle:@"Ok"
     otherButtonTitles:nil];
     [alertView show];
     }
     
     */
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if ([[NSUserDefaults standardUserDefaults]objectForKey:kXMPPmyJID]) {
        self.userName.text = [[NSUserDefaults standardUserDefaults]objectForKey:kXMPPmyJID];
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:kXMPPmyPassword]) {
        self.userPassword.text = [[NSUserDefaults standardUserDefaults]objectForKey:kXMPPmyPassword];
    }
    self.userPassword.secureTextEntry = YES;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload {
    [self setUserName:nil];
    [self setUserPassword:nil];
    [super viewDidUnload];
}
- (IBAction)didClickRegister:(UIButton *)sender {
    RegisterViewController *registerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RegisterViewController"];
    [self.navigationController pushViewController:registerVC animated:YES];
}

- (IBAction)testLogin:(UIButton *)sender
{
    SidebarViewController *sidebarVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SidebarViewController"];
    
    [self.navigationController pushViewController:sidebarVC animated:YES];
}

- (IBAction)didClickLogin:(UIButton *)sender
{
    
    [self didClickLoginButton:nil];
    
}

-(void)didClickLoginButton:(id)sender
{
    
    if ( self.userName.text && self.userPassword.text)
    {
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kXMPPmyJID];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kXMPPmyPassword];
        [[NSUserDefaults standardUserDefaults] setObject:self.userName.text forKey:kXMPPmyJID];
        [[NSUserDefaults standardUserDefaults] setObject:self.userPassword.text forKey:kXMPPmyPassword];
        [[XMPPManager instence]connect];
        
        
    }else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"登陆失败"
                                                            message:@"请输入用户名或者密码！"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];

        
        NSLog(@"登陆失败");
    }
    
    
    
    

}

#pragma mark - xmppmanager Delegate
-(void)authenticateSuccessed
{
    [self testLogin:nil];
}
-(void)authenticateFailed
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"登陆失败"
                                                        message:@"用户名或者密码错误！"
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kXMPPmyJID];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kXMPPmyPassword];
    [[XMPPManager instence]disconnect];
    
}

#pragma UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([userName resignFirstResponder]||
        [userPassword resignFirstResponder]) {
        return YES;
    }
    return NO;
}

@end
