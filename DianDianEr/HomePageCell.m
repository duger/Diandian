//
//  HomePageCell.m
//  DianDianEr
//
//  Created by 王超 on 13-10-23.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "HomePageCell.h"

@implementation HomePageCell
{
    NCMusicEngine *_player;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.playButton = [[Mp3PlayerButton alloc]initWithFrame:CGRectMake(self.mainView.bounds.origin.x+185, self.mainView.bounds.origin.y-8, 30, 30)];
    [self.mainView addSubview:self.playButton];
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    //    self.playButton = [[Mp3PlayerButton alloc]init];
    self.mainView.frame = CGRectMake(88, self.bounds.size.height - 30, 222, 19);
    self.shareImage.frame = CGRectMake(10, self.bounds.size.height-80, 70, 70);
    //    self.playButton.frame = CGRectMake(self.mainView.bounds.origin.x+185, self.mainView.bounds.origin.y-8, 30, 30);
    //    [self.mainView addSubview:self.playButton];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
