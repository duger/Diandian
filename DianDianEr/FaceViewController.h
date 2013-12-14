

#import <UIKit/UIKit.h>

@class MessagesViewController;


@interface FaceViewController : UIViewController<UITableViewDataSource,UITableViewDelegate> {
	NSMutableArray            *_phraseArray;
	MessagesViewController        *_messagesViewController;
    
    
}

@property (retain, nonatomic) IBOutlet UIScrollView *faceScrollView;
@property (nonatomic, retain) NSMutableArray            *phraseArray;
@property (nonatomic, retain) MessagesViewController        *messagesViewController;

-(IBAction)dismissMyselfAction:(id)sender;
- (void)showEmojiView;
@end
