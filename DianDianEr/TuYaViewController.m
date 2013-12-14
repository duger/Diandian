//
//  TuYaViewController.m
//  DianDianEr
//
//  Created by 信徒 on 13-10-22.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "TuYaViewController.h"
#import "UIColor+Random.h"
#import "Singleton.h"
#import "ShareManager.h"
#import "ShareViewController.h"


@implementation TuYaViewController
{
    NSString * filePath;
}
@synthesize aPainterView;
@synthesize aImage;
@synthesize aImageData;


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
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"leftBackground320*480"]];
     self.topView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"NavBar_meitu_5.png"]];
    aPainterView = [[PainterView alloc] initWithFrame:CGRectMake(20, 52, 280, 300)];
    [self.view addSubview:aPainterView];
}

- (IBAction)changeLineWidth:(UISlider *)sender
{
    aPainterView.lineWidth = sender.value;
    
}
- (IBAction)changeLineColor:(UISegmentedControl *)sender
{
    switch (sender.selectedSegmentIndex) {
        case 0:
            aPainterView.color = [UIColor redColor];
            break;
        case 1:
            aPainterView.color = [UIColor greenColor];
            break;
        case 2:
            aPainterView.color = [UIColor blueColor];
            break;
        case 3:
            aPainterView.color = [UIColor randomColor];
            break;
            
        default:
            break;
    }
}
- (IBAction)rubber:(UIButton *)sender
{
    [aPainterView erase];
}
- (IBAction)clear:(UIButton *)sender
{
    [aPainterView resetView];
    aPainterView.color = [UIColor blackColor];
    aPainterView.lineWidth = 5.0f;
   
}
- (IBAction)redo:(UIButton *)sender
{
    [aPainterView re];
}
- (IBAction)undo:(UIButton *)sender
{
    [aPainterView un];
}
- (IBAction)save:(UIButton *)sender
{
    static int i = 0;
    NSString * documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    filePath = [documentPath stringByAppendingFormat:@"/%d.png",i++];
    [self getCurrentImage];
    
    aImageData = [NSKeyedArchiver archivedDataWithRootObject:aImage];
    [aImageData writeToFile:filePath atomically:YES];
    
    UIImageWriteToSavedPhotosAlbum(aImage, nil, nil, nil);


    
}

- (IBAction)changebackround:(UIButton *)sender
{
    aPainterView.aBackgroundColor = [UIColor randomColor];
    [aPainterView changeBackground];
}

- (UIImage *)getCurrentImage
{
    UIGraphicsBeginImageContext(aPainterView.bounds.size);
    [aPainterView.layer renderInContext:UIGraphicsGetCurrentContext()];
    aImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return aImage;
}
- (IBAction)didClickBack:(UIBarButtonItem *)sender
{
//    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        nil;
    }];
    
}
- (IBAction)didClickShare:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        if ([Singleton instance].fromTuYa) {
            [self.delegate tuYaGoToShare];
        }
    }];
//    ShareViewController *shareVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ShareViewController"];
//    shareVC.delegate = self;
//    [self.navigationController pushViewController:shareVC animated:YES];


//    [self dismissViewControllerAnimated:YES completion:^{
//        nil;
//    }];
//    ShareViewController *shareVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ShareViewController"];
////    [self.navigationController pushViewController:shareVC animated:YES];
//    [self dismissViewControllerAnimated:YES completion:^{
//        nil;
//    }];
    static int i = 0;
    NSString * documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    filePath = [documentPath stringByAppendingFormat:@"/%d.png",i++];
    UIImage *image = [self getCurrentImage];
//    aImageData = [NSKeyedArchiver archivedDataWithRootObject:aImage];
    aImageData = UIImagePNGRepresentation(image);
    [aImageData writeToFile:filePath atomically:YES];
    UIImageWriteToSavedPhotosAlbum(aImage, nil, nil, nil);
    [ShareManager defaultManager].tempImagePath = filePath;
//    shareVC.shareImage.image = image;
    if (![Singleton instance].fromTuYa) {
        [self.delegate didFinishTuYa];
    }

}

- (void)viewDidUnload
{
    [self setTopView:nil];
    [super viewDidUnload];
}
@end
