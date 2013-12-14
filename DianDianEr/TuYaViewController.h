//
//  TuYaViewController.h
//  DianDianEr
//
//  Created by 信徒 on 13-10-22.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PainterView.h"
@protocol  TuYaViewControllerDelegate<NSObject>
-(void)didFinishTuYa;
-(void)tuYaGoToShare;
@end
@interface TuYaViewController : UIViewController
@property (weak,nonatomic) id <TuYaViewControllerDelegate>delegate;
@property(strong, nonatomic)PainterView     *aPainterView;
@property(strong, nonatomic)UIImage         *aImage;
@property(strong, nonatomic)NSData          *aImageData;

@property (strong, nonatomic) IBOutlet UIView *topView;

- (IBAction)changeLineWidth:(UISlider *)sender;
- (IBAction)changeLineColor:(UISegmentedControl *)sender;
- (IBAction)changebackround:(UIButton *)sender;

- (IBAction)rubber:(UIButton *)sender;
- (IBAction)clear:(UIButton *)sender;
- (IBAction)redo:(UIButton *)sender;
- (IBAction)undo:(UIButton *)sender;
- (IBAction)save:(UIButton *)sender;


- (IBAction)didClickBack:(UIBarButtonItem *)sender;
- (IBAction)didClickShare:(UIBarButtonItem *)sender;

@end
