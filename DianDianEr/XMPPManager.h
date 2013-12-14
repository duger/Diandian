//
//  XMPPManager.h
//  DianDianEr
//
//  Created by Duger on 13-10-24.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
#import "TURNSocket.h"
#import "TURNSocket.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@protocol XMPPManagerDelegate <NSObject>

-(void )reloadTableView;
-(void)authenticateSuccessed;
-(void)authenticateFailed;
-(void)leaveRegister;

@end

@interface XMPPManager : NSObject<XMPPRosterDelegate>
{
	XMPPStream *xmppStream;
	XMPPReconnect *xmppReconnect;
    XMPPRoster *xmppRoster;
	XMPPRosterCoreDataStorage *xmppRosterStorage;
    XMPPvCardCoreDataStorage *xmppvCardStorage;
	XMPPvCardTempModule *xmppvCardTempModule;
	XMPPvCardAvatarModule *xmppvCardAvatarModule;
	XMPPCapabilities *xmppCapabilities;
	XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
	TURNSocket * turnSocket;
	NSString *password;
	
	BOOL allowSelfSignedCertificates;
	BOOL allowSSLHostNameMismatch;
	
	BOOL isXmppConnected;
    BOOL isRegister;
    NSString *jidWithResouce;
    NSString *proxyHost;
    NSString *proxyPort;
    NSString *proxyJID;
    GCDAsyncSocket *mySocket;
    AVAudioRecorder *recorder;
    NSURL *urlPlay;
}
///单例
+(XMPPManager *)instence;


@property(retain,nonatomic) NSMutableArray *roster;
@property (nonatomic,retain) NSString *toSomeOne;
//@property(nonatomic,assign) id<XMPPViewControllerDelegate> delegate;

-(void)sendMyMessage:(NSXMLElement *)message;


@property (retain, nonatomic) AVAudioPlayer *avPlay;

//-----------------------------------------------------------------------------------------
@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
@property (nonatomic, strong, readonly) TURNSocket *turnSocket;
@property (nonatomic,strong) NSString *jidWithResouce;
- (NSManagedObjectContext *)managedObjectContext_roster;
- (NSManagedObjectContext *)managedObjectContext_capabilities;

- (BOOL)connect;
- (void)disconnect;
- (void)setupStream;
- (void)teardownStream;
- (void)goOnline;
- (void)goOffline;
-(BOOL)authenticate;
//------------------------------------------------------------------------------------------

@property (nonatomic, strong) XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage;
@property (nonatomic, strong) XMPPMessageArchiving *xmppMessageArchivingModule;

//-----------------------------------------------------------------------------------------
@property (strong, nonatomic) IBOutlet UITextField *hostTextField;
@property (strong, nonatomic) IBOutlet UITextField *portTextField;
@property (strong, nonatomic) IBOutlet UITextField *messageTextField;
@property (strong, nonatomic) IBOutlet UITextField *userNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UITextField *toTextField;
@property (strong, nonatomic) IBOutlet UITextField *addFriendTextField;
@property (strong, nonatomic) IBOutlet UITextView *informationTextView;
- (IBAction)sendAttechment:(id)sender;
- (IBAction)connectXMPP:(id)sender;
- (IBAction)sendMessage:(id)sender;
- (IBAction)registerInSide:(NSString *)userName andPassword:(NSString *)thePassword;
- (IBAction)addNewFriend:(NSString*)newFriendName;
- (IBAction)uploadAudio:(id)sender;
- (IBAction)play:(id)sender;
- (IBAction)printCoreData:(id)sender;


//------------------------------------------------------------------------------------------
///my method
-(void)showAlertView:(NSString *)message;

@property (nonatomic,assign) id<XMPPManagerDelegate> delegate;

@end


