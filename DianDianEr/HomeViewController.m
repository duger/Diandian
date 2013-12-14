//
//  HomeViewController.m
//  DianDianEr
//
//  Created by 王超 on 13-10-18.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "HomeViewController.h"
#import "LeftSideBarViewController.h"
#import "HomePageCell.h"
#import "DiandianCoreDataManager.h"
#import "UIImageView+WebCache.h"


@interface HomeViewController ()<NCMusicEngineDelegate>

@end

@implementation HomeViewController
{
    Mp3PlayerButton *playButton;
    NCMusicEngine *_player;
}

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
    self.shareArray = [[NSMutableArray alloc]init];
    self.topView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"NavBar_meitu_5.png"]];
    [self.tableView registerClass:[HomePageCell class] forCellReuseIdentifier:@"HomePageCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"HomePageCell" bundle:nil] forCellReuseIdentifier:@"HomePageCell"];

    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Background.png"]];
    self.tableView.frame = CGRectMake(0, self.topView.frame.origin.y + self.topView.frame.size.height , 320, kHEIGHT_SCREEN - self.topView.frame.origin.y - self.topView.frame.size.height-20);
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.shareArray addObjectsFromArray:[[DiandianCoreDataManager shareDiandianCoreDataManager] myShare]];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}


- (IBAction)didClickBack:(UIBarButtonItem *)sender
{
//    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.shareArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat textHeight = 0.0f;
    CGFloat imageHeight = 0.0f;
    Share *share = [self.shareArray objectAtIndex:[self.shareArray count] - indexPath.row - 1];
    NSString *text = share.s_content;
    CGSize max = CGSizeMake(320, 1000.0f);
    CGSize labelsize = [text sizeWithFont:[UIFont fontWithName:nil size:12.0f] constrainedToSize:max lineBreakMode:UILineBreakModeCharacterWrap];
    textHeight = labelsize.height;
    NSLog(@"笨蛋%@",share.s_image_url);
    if ([share.s_image_url isEqualToString:@"http://124.205.147.26/student/class_10/team_seven/resource/images"]) {
        
        return textHeight + 135;
    }
    imageHeight = 70.0f;
    return textHeight + imageHeight + 110;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"HomePageCell";
    HomePageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.layer.borderWidth = 0.5f;
    cell.layer.borderColor = [UIColor grayColor].CGColor;
    
    Share *share = [self.shareArray objectAtIndex: [self.shareArray count] - indexPath.row - 1];
//    NSLog(@"哈哈哈哈%@",share);
    cell.timeLabel.text = share.s_createdate;
    cell.nameLabel.text = share.s_user_id;
    cell.shareLabel.text = share.s_content;
    cell.addressLabel.text = share.s_locationName;
    cell.headName.image = [UIImage imageNamed:@"形状-2.png"];
    if (!share.s_image_url ) {
    }
    else
    {
        NSURL *url = [NSURL URLWithString:share.s_image_url];
        NSLog(@"%@",url);
        [cell.shareImage setImageWithURL:url placeholderImage:[UIImage imageNamed:@"LOG-IN.png"]];
        
    }
    
    if ([share.s_sound_url isEqualToString:@"http://124.205.147.26/student/class_10/team_seven/resource/sounds"])
    {
        cell.playButton.hidden = YES;
    }
    else
    {
        cell.playButton.hidden = NO;
        cell.playButton.mp3URL = [NSURL URLWithString:share.s_sound_url];
        [cell.playButton addTarget:self action:@selector(playAudio:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}

- (void)playAudio:(Mp3PlayerButton *)button
{
    if (_player == nil) {
        _player = [[NCMusicEngine alloc] init];
        //_player.button = button;
        _player.delegate = self;
    }
    
    if ([_player.button isEqual:button]) {
        if (_player.playState == NCMusicEnginePlayStatePlaying) {
            [_player pause];
        }
        else if(_player.playState==NCMusicEnginePlayStatePaused){
            [_player resume];
        }
        else{
            [_player playUrl:button.mp3URL];
        }
    } else {
        [_player stop];
        _player.button = button;
        [_player playUrl:button.mp3URL];
    }
}

- (void)viewDidUnload {
    [self setNavigationbar:nil];
    [self setTopView:nil];
    [super viewDidUnload];
}
@end
