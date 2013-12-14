//
//  SystemViewController.m
//  DianDianEr
//
//  Created by 王超 on 13-10-21.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "SystemViewController.h"
#import "LoginViewController.h"

@interface SystemViewController ()
{
    UILabel *lable;
    UITextView * textView;
}

@end

@implementation SystemViewController
@synthesize aTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
       
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.topView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"NavBar_meitu_5.png"]];
    
     aTableView = [[UITableView alloc] initWithFrame:CGRectMake(self.topView.frame.origin.x, self.topView.frame.origin.y+self.topView.frame.size.height,kWIDTH_SCREEN,kHEIGHT_SCREEN - 60) style:UITableViewStyleGrouped];
    [self.view addSubview:aTableView];
    aTableView.dataSource = self;
    aTableView.delegate = self;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark TableView Datesource方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    switch (section) {
//        case 0:
//            return 2;
//            break;
//        case 1:
//            return 1;
//            break;
//        case 2:
//            return 9;
//            break;
//        case 3:
//            return 1;
//            break;
//        case 4:
//            return 1;
//            break;
//        case 5:
//            return 5;
//            break;
//        case 6:
//            return 2;
//            break;            
//        default:
//            break;
//    }
//    return 0;
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 2;
            break;
            
        default:
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier_section_0 = @"cellIdentifier_section_0";//默认
    static NSString *cellIdentifier_section_1 = @"cellIdentifier_section_1";//消息和手机
    static NSString *cellIdentifier_section_2 = @"cellIdentifier_section_2";//连接
    static NSString *cellIdentifier_section_3 = @"systemStyle";//系统
    static NSString *cellIdentifier_section_4 = @"cellIdentifier_section_4";//清理缓存
    CustomTypeCell * cell = nil;
    switch (indexPath.section)
    {
//        case 0:
//        {
//            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier_section_0];
//            if (cell == nil)
//            {
//                cell = [[CustomTypeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier_section_0 cellType:CelldefaultType];
//                cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            }
//            NSArray * array = @[@"已启用",@"附近的信息"];
//            cell.textLabel.text = [array objectAtIndex:indexPath.row];
//            cell.textLabel.font = [UIFont fontWithName:@"Optima" size:16];
//            [cell     refresh];
//            [cell     setDelegate:self];
//        }
//            break;
        case 0:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier_section_4];
            if (cell == nil)
            {
                cell = [[CustomTypeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier_section_4 cellType:CellClearCach];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.clearLabel.text = @"清理缓存";
            cell.clearBtn.tag = 100;
            cell.clearLabel.font = [UIFont fontWithName:@"Optima" size:16];
            [cell     setDelegate:self];
        }
            break;
            
//        case 2:
//        {
//            if (indexPath.row < 6)
//            {
//                cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier_section_1];
//                if (cell == nil)
//                {
//                    cell = [[CustomTypeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier_section_1 cellType:CellMessgaeAndPhoneType];
//                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//                }
//                NSArray * array = @[@"好友请求",@"好友发布的信息",@"我发布的信息",@"评论",@"心情",@"闪屏振动"];
//                cell.textLabel.font = [UIFont fontWithName:@"Optima" size:16];
//                cell.textLabel.text = [array objectAtIndex:indexPath.row];
//                [cell refresh2];
//                [cell refresh3];
//                [cell setDelegate:self];
//            }
//            else
//            {
//                cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier_section_0];
//                if (cell == nil)
//                {
//                    cell = [[CustomTypeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier_section_0 cellType:CelldefaultType];
//                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//                }
//                NSArray * array = @[@"消息",@"分享照片提醒",@"分享音乐提醒"];
//                cell.textLabel.font = [UIFont fontWithName:@"Optima" size:16];
//                cell.textLabel.text = [array objectAtIndex:indexPath.row - 6];
//                [cell  refresh];
//                [cell  setDelegate:self];
//            }
//            break;
//            
//        case 3:
//            {
//                cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier_section_0];
//                if (cell == nil)
//                {
//                    cell = [[CustomTypeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier_section_0 cellType:CelldefaultType];
//                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//                }
//                cell.textLabel.text = @"显示消息预览";
//                cell.textLabel.font = [UIFont fontWithName:@"Optima" size:16];
//                [cell  refresh];
//                [cell  setDelegate:self];
//            }
//            break;
//            
//        case 4:
//            {
//                cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier_section_0];
//                if (cell == nil)
//                {
//                    cell = [[CustomTypeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier_section_0 cellType:CelldefaultType];
//                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//                }
//                cell.textLabel.text = @"音效";
//                cell.textLabel.font = [UIFont fontWithName:@"Optima" size:16];
//                [cell refresh];
//                [cell setDelegate:self];
//            }
//            break;
//            
//        case 5:
//            {
//                cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier_section_2];
//                if (cell == nil)
//                {
//                    cell = [[CustomTypeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier_section_2 cellType:CellConnectType];
//                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//                }
//                NSArray * titleArray = @[@"Facebook",@"Twitter",@"Tumbir",@"Foursquare",@"Gmail"];
//                NSArray * iamgeArray = @[@"Retina-Home-Screen---114px",@"Profile",@"bg-addbutton@2x",@"bg-menuitem-highlighted@2x",@"Settings-bg@2x"];
//                cell.connectImageView.image = [UIImage imageNamed:[iamgeArray objectAtIndex:indexPath.row] ];
//                cell.connectLabel.text = [titleArray objectAtIndex:indexPath.row];
//                [cell refresh4];
//                [cell setDelegate:self];
//            }
//            break;
        case 1:
            {
                cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier_section_3];
                if (cell == nil)
                {
                    cell = (CustomTypeCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier_section_3];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                NSArray * array = @[@"关于",@"注销"];
                cell.textLabel.textAlignment = 1;
                cell.textLabel.text = [array objectAtIndex:indexPath.row];
                cell.textLabel.font = [UIFont fontWithName:@"Optima" size:16.0];
            }
            break;
        
    }
     return cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
//    NSArray * array = @[@"位置",@"缓存",@"通知",@" ",@"音频",@"分享中",@" ",@""];
   NSArray * array = @[@"缓存",@""];
    NSString * title = [array objectAtIndex:section];
    return title;
}


#pragma mark TableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && aTableView.frame.origin.x >= 0) {
        switch (indexPath.row) {
            case 0:
            {
                textView = [[UITextView alloc] initWithFrame:CGRectMake(70, self.topView.frame.origin.y+self.topView.frame.size.height, kWIDTH_SCREEN -60, kHEIGHT_SCREEN - self.topView.frame.origin.y+self.topView.frame.size.height)];
                CATransition *animation = [CATransition animation];
                animation.duration = 1.0f;
                animation.delegate = self;
                animation.timingFunction = UIViewAnimationCurveEaseInOut;
                animation.type = kCATransitionPush;
                animation.subtype = kCATransitionFromRight;
                
                [[textView layer] addAnimation:animation forKey:@"动画效果"];
                [[aTableView layer] addAnimation:animation forKey:@"过度动画"];

                aTableView.frame = CGRectMake(70 - kWIDTH_SCREEN, self.topView.frame.origin.y+self.topView.frame.size.height,kWIDTH_SCREEN,kHEIGHT_SCREEN - 60);
                textView.textAlignment = 1;
                textView.text = @"                                                                 点点儿项目组  \n                                                                     蓝鸥科技研发中心 ";
                textView.font = [UIFont systemFontOfSize:19.0f];
                textView.textColor = [UIColor blackColor];
                textView.backgroundColor = [UIColor grayColor];
                textView.alpha = 0.7f;
                textView.editable = NO;
                textView.tag = 100;
                [self.view addSubview:textView];
                
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRemoveTextView)];
                [textView addGestureRecognizer:tap];
                break;
            }
          case 1:
            {
                NSLog(@"2");
                LoginViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kXMPPmyJID];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kXMPPmyPassword];
                [[XMPPManager instence] disconnect];
                [[XMPPManager instence] teardownStream];
                [self.navigationController pushViewController:loginVC animated:YES];

            }
                
            default:
                break;
        }
    }
}

- (IBAction)didClickBack:(UIBarButtonItem *)sender
{
//    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)asdiohfvsalkjvhdsalkjfvbhasdjk:(CustomTypeCell *)sender
{
    NSLog(@"开关状态口%@",sender);
    [sender refresh];
}

-(void)phoneIsOn:(CustomTypeCell *)sender
{
    NSLog(@"电话状态%@",sender);
    [sender refresh2];
    
}
-(void)messageIsOn:(CustomTypeCell *)sender
{
    NSLog(@"消息状态%@",sender);
    [sender refresh3];
}
-(void)connectIsOn:(CustomTypeCell *)sender
{
    NSLog(@"连接状态%@",sender);
    
    [sender refresh4];
}
- (void)viewDidUnload {
    [self setTopView:nil];
    [super viewDidUnload];
}

- (void)tapRemoveTextView
{
    CATransition *animation = [CATransition animation];
    animation.duration = 1.0f;
    animation.delegate = self;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromLeft;
    
    [[textView layer] addAnimation:animation forKey:@"动画效果"];
    [[aTableView layer] addAnimation:animation forKey:@"过度动画"];
    textView.frame = CGRectMake(kWIDTH_SCREEN, self.topView.frame.origin.y+self.topView.frame.size.height, kWIDTH_SCREEN -60, kHEIGHT_SCREEN - self.topView.frame.origin.y+self.topView.frame.size.height);
    
    aTableView.frame = CGRectMake(self.topView.frame.origin.x, self.topView.frame.origin.y+self.topView.frame.size.height,kWIDTH_SCREEN,kHEIGHT_SCREEN - 60);
}
-(void)clearCach:(UIButton *)btn
{
    [btn setTitle:@"清理中..." forState:UIControlStateNormal];
    NSArray *tempArray = [[DiandianCoreDataManager shareDiandianCoreDataManager] all_share];
    for (NSManagedObject *object  in tempArray) {
        [[DiandianCoreDataManager shareDiandianCoreDataManager] delete_a_share:object];
    };
    [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(removeSQL) userInfo:nil repeats:NO];
}
- (void)removeSQL
{
    UIButton * btn = (UIButton *)[self.view viewWithTag:100];
    [btn setTitle:@"已清空" forState:UIControlStateNormal];
}
@end
