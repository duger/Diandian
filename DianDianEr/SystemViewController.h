//
//  SystemViewController.h
//  DianDianEr
//
//  Created by 王超 on 13-10-21.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTypeCell.h"

@interface SystemViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,CustomTypeCellDelegate>

@property(strong ,nonatomic)UITableView *aTableView;

- (IBAction)didClickBack:(UIBarButtonItem *)sender;
@property (strong, nonatomic) IBOutlet UIView *topView;

@end
