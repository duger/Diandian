//
//  RightSideBarViewController.m
//  DianDianEr
//
//  Created by 王超 on 13-10-18.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "RightSideBarViewController.h"
#import "AKTabBarController.h"
#import "FriendsViewController.h"
#import "MessagesViewController.h"
#import "TipsViewController.h"
#import "ChartViewController.h"
#import "MapViewController.h"


@interface RightSideBarViewController ()

@end

@implementation RightSideBarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    {
//        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BG1.png"]];
        [self setTabBarHeight:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 70 : 50];
        
        [self setMinimumHeightToDisplayTitle:40.0];
        
        FriendsViewController *firendsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendsViewController"];
        firendsVC.delegate = self;
//        UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:nil action:nil];
//        self.navigationItem.backBarButtonItem = backItem;
//        MessagesViewController *messageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MessagesViewController"];

        MapViewController *mapVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];

        
        [self setViewControllers:[NSMutableArray arrayWithObjects:
                                               firendsVC,
                                               mapVC,nil]];
        
        
        
    }
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)goToChartroom
{
    ChartViewController *chartVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ChartViewController"];
    
    [self presentViewController:chartVC animated:YES completion:^{}];
    
//    ChartingViewController *chartingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ChartingViewController"];
//    [self.navigationController pushViewController:chartingVC animated:YES];
    
}

@end
