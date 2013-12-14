//
//  XMPPManager.m
//  DianDianEr
//
//  Created by Duger on 13-10-24.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "XMPPManager.h"
#import "GCDAsyncSocket.h"
#import "XMPP.h"
#import "XMPPReconnect.h"
#import "XMPPCapabilitiesCoreDataStorage.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPvCardAvatarModule.h"
#import "XMPPvCardCoreDataStorage.h"
#import "XMPPRosterMemoryStorage.h"

#import "DDLog.h"
#import "DDTTYLogger.h"
#import "NSData+Base64.h"
#import "NSString+Base64.h"
#import "XMPPManager.h"

#import <CFNetwork/CFNetwork.h>
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@implementation XMPPManager
static XMPPManager *s_XMPPManager = nil;
+(XMPPManager *)instence
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (s_XMPPManager == nil) {
            s_XMPPManager = [[XMPPManager alloc]init];
            
        }
    });
    return s_XMPPManager;
}

@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize xmppRoster;
@synthesize xmppRosterStorage;
@synthesize xmppvCardTempModule;
@synthesize xmppvCardAvatarModule;
@synthesize xmppCapabilities;
@synthesize xmppCapabilitiesStorage;
@synthesize turnSocket;
@synthesize jidWithResouce;
@synthesize avPlay;

@synthesize xmppMessageArchivingCoreDataStorage;
@synthesize xmppMessageArchivingModule;




#define tag_subcribe_alertView 10

- (id)init
{
    self = [super init];
    if (self) {
        proxyHost = [[NSString alloc]init];
        proxyPort = [[NSString alloc]init];
        proxyJID = [[NSString alloc]init];
        
        if ([[NSUserDefaults standardUserDefaults]objectForKey:kXMPPmyJID]) {
            self.userNameTextField.text = [[NSUserDefaults standardUserDefaults]objectForKey:kXMPPmyJID];
        }
        if ([[NSUserDefaults standardUserDefaults]objectForKey:kXMPPmyPassword]) {
            self.passwordTextField.text = [[NSUserDefaults standardUserDefaults]objectForKey:kXMPPmyPassword];
        }
        jidWithResouce = [[NSString alloc] init];
        //        [self setupStream];
        self.roster = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)dealloc
{
	[self teardownStream];
}

#pragma mark -
- (void)goOnline
{
    NSLog(@"goOnline");
	XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
	
	[[self xmppStream] sendElement:presence];
}

- (void)goOffline
{
    NSLog(@"goOffline");
	XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
	
	[[self xmppStream] sendElement:presence];
}

- (void)setupStream{
    xmppStream = [[XMPPStream alloc] init];
    
    [xmppStream setHostName:@"124.205.147.26"];
	[xmppStream setHostPort:5222];
    // Setup reconnect
	//
	// The XMPPReconnect module monitors for "accidental disconnections" and
	// automatically reconnects the stream for you.
	// There's a bunch more information in the XMPPReconnect header file.
	
	xmppReconnect = [[XMPPReconnect alloc] init];
	
	// Setup roster
	//
	// The XMPPRoster handles the xmpp protocol stuff related to the roster.
	// The storage for the roster is abstracted.
	// So you can use any storage mechanism you want.
	// You can store it all in memory, or use core data and store it on disk, or use core data with an in-memory store,
	// or setup your own using raw SQLite, or create your own storage mechanism.
	// You can do it however you like! It's your application.
	// But you do need to provide the roster with some storage facility.
	
	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
      xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
	
	xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
	
	xmppRoster.autoFetchRoster = YES;
	xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
	
	
	xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
	xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
	
	xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
	
    
	
	xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];
    
    xmppCapabilities.autoFetchHashedCapabilities = YES;
    xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
	// Activate xmpp modules
    
	[xmppReconnect         activate:xmppStream];
	[xmppRoster            activate:xmppStream];
	[xmppvCardTempModule   activate:xmppStream];
	[xmppvCardAvatarModule activate:xmppStream];
	[xmppCapabilities      activate:xmppStream];
    
	// Add ourself as a delegate to anything we may be interested in
    
	[xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
	[xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
	
    //	[xmppStream setHostName:@"saas.kanyabao.com"];
    //	[xmppStream setHostPort:5222];
	
    allowSelfSignedCertificates = NO;
	allowSSLHostNameMismatch = NO;
    
    xmppMessageArchivingCoreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    xmppMessageArchivingModule = [[XMPPMessageArchiving alloc]initWithMessageArchivingStorage:xmppMessageArchivingCoreDataStorage];
    [xmppMessageArchivingModule setClientSideMessageArchivingOnly:YES];
    [xmppMessageArchivingModule activate:xmppStream];
    [xmppMessageArchivingModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    
    
    
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Connect/disconnect
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)registerInSide:(NSString *)userName andPassword:(NSString *)thePassword{
    isRegister = YES;
    NSError *err;
    NSString *tjid = [[NSString alloc] initWithFormat:@"%@@%@",userName,@"124.205.147.26"];  //smack
    password = thePassword;
    XMPPJID *jid = [XMPPJID jidWithString:tjid resource:@"XMPP"];
    [xmppStream setMyJID:jid];
    
        
        if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&err]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"连接服务器失败" message:[err localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        }
    
    
}

-(void)_registerNow
{
    NSError *err;
    if (![xmppStream registerWithPassword:password error:&err]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"创建帐号失败" message:[err localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    }else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"创建帐号成功" message:[err localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//        [alertView show];
        NSLog(@"成功注册啦");
    }
    
}

- (IBAction)addNewFriend:(NSString*)newFriendName {
    XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",newFriendName,@"124.205.147.26"]];
	
	[[self xmppRoster] addUser:jid withNickname:newFriendName];
	
	// Clear buddy text field
    
}

- (IBAction)uploadAudio:(id)sender {
    //ca9f3948472ebbe940fbc16f76bccb95
    //    NSURL *recordedFile = [NSURL URLWithString:[[NSBundle mainBundle]pathForResource:@"endgame" ofType:@"wav"]];
    NSData * soundData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"msg" ofType:@"amr"]];
    NSLog(@"%d",soundData.length);
    NSString *sound=[soundData base64EncodedString];
    NSLog(@"%d",sound.length);
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/msg.amr"];
    NSError *error = nil;
    BOOL write = [sound writeToFile:path atomically:YES encoding: NSUTF8StringEncoding error:&error];
    if (write) {
        NSLog(@"yes");
    }else{
        NSLog(@"no %@",error.description);
    }
    //    NSLog(@"%@",sound);
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    // [body setStringValue:@"image"];
    
    NSXMLElement *attachment = [NSXMLElement elementWithName:@"attachment"];
    [attachment setStringValue:sound];
    
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@124.205.147.26/XMPP",self.toTextField.text]];
    [message addChild:body];
    [message addChild:attachment];
    [self.xmppStream sendElement:message];
    //    UIImage *selectedImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"camer" ofType:@"png"]];
    //    NSData *dataObjww = UIImageJPEGRepresentation(selectedImage,0);
    //
    //    NSString *strMessage;
    //
    //    strMessage = [dataObjww base64EncodedString];
    
    
    //    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    //    [body setStringValue:@"image"];
    //
    //    NSXMLElement *attachment = [NSXMLElement elementWithName:@"attachment"];
    //    [attachment setStringValue:strMessage];
    //
    //    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    //    [message addAttributeWithName:@"type" stringValue:@"chat"];
    //    [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@saas.kanyabao.com",self.toTextField.text]];
    //    [message addChild:body];
    //    [message addChild:attachment];
    //    [self.xmppStream sendElement:message];
    
    NSXMLElement *xmlBody = [NSXMLElement elementWithName:@"body"];
    [xmlBody setStringValue:sound];
    NSXMLElement *xmlMessage = [NSXMLElement elementWithName:@"message"];
    [xmlMessage addAttributeWithName:@"type" stringValue:@"chat"];
    [xmlMessage addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@124.205.147.26",self.toTextField.text]];
    [xmlMessage addChild:xmlBody];
    [self.xmppStream sendElement:xmlMessage];
    
}

- (IBAction)play:(id)sender {
    //    NSString *strUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/test.wav", strUrl]];
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/test.amr"];
    
    AVAudioPlayer *player = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:path] error:nil];
    self.avPlay = player;
    [self.avPlay play];
}

- (IBAction)printCoreData:(id)sender {
    NSManagedObjectContext *context = [xmppMessageArchivingCoreDataStorage mainThreadManagedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entityDescription];
    NSError *error ;
    NSArray *messages = [context executeFetchRequest:request error:&error];
    [self print:[[NSMutableArray alloc]initWithArray:messages]];
}
-(void)print:(NSMutableArray*)messages{
    @autoreleasepool {
        for (XMPPMessageArchiving_Message_CoreDataObject *message in messages) {
            NSLog(@"messageStr param is %@",message.messageStr);
            NSXMLElement *element = [[NSXMLElement alloc] initWithXMLString:message.messageStr error:nil];
            NSLog(@"to param is %@",[element attributeStringValueForName:@"to"]);
            NSLog(@"NSCore object id param is %@",message.objectID);
            NSLog(@"bareJid param is %@",message.bareJid);
            NSLog(@"bareJidStr param is %@",message.bareJidStr);
            NSLog(@"body param is %@",message.body);
            NSLog(@"timestamp param is %@",message.timestamp);
            NSLog(@"outgoing param is %d",[message.outgoing intValue]);
        }
    }
}

- (void)saveHistory:(XMPPMessage *)message {
    NSManagedObjectContext *context = [xmppMessageArchivingCoreDataStorage mainThreadManagedObjectContext];
    XMPPMessageArchiving_Message_CoreDataObject *messageObject = [NSEntityDescription insertNewObjectForEntityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:context];//NSManagedObject
    [messageObject setBareJid:message.to];
    [messageObject setBareJidStr:message.toStr];
    [messageObject setBody:message.body];
    [messageObject setMessage:message];
    [messageObject setTimestamp:[NSDate date]];
    [messageObject setIsOutgoing:YES];
    [messageObject setStreamBareJidStr:message.body];
    NSError *error ;
    if (![context save:&error]) {
        NSLog(@"data not save to database : %@",error.description);
    }
    
}
- (BOOL)connect
{
    if (![xmppStream isDisconnected]) {
        return YES;
    }
    
    
	NSString *myJID = [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyJID];
	NSString *myPassword = [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyPassword];
    
    NSLog(@"%@",myJID);
	//
	// If you don't want to use the Settings view to set the JID,
	// uncomment the section below to hard code a JID and password.
	//
	// myJID = @"user@gmail.com/xmppframework";
	// myPassword = @"";
    
    if (myJID == nil || myPassword == nil) {
		return NO;
	}
    
	myJID = [NSString stringWithFormat:@"%@@%@",myJID,@"124.205.147.26"];
    //    myPassword = self.passwordTextField.text;
	
    XMPPJID *jid = [XMPPJID jidWithString:myJID resource:@"XMPP"];
	[xmppStream setMyJID:jid];
	password = myPassword;
    
	NSError *error = nil;
	if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting"
		                                                    message:@"See console for error details."
		                                                   delegate:nil
		                                          cancelButtonTitle:@"Ok"
		                                          otherButtonTitles:nil];
		[alertView show];
        NSLog(@"%@",@"error connecting");
        
		return NO;
	}
    return YES;
}

- (void)disconnect
{
	[self goOffline];
	[xmppStream disconnect];
}
- (void)teardownStream
{
	[xmppStream removeDelegate:self];
	[xmppRoster removeDelegate:self];
	
	[xmppReconnect         deactivate];
	[xmppRoster            deactivate];
	[xmppvCardTempModule   deactivate];
	[xmppvCardAvatarModule deactivate];
	[xmppCapabilities      deactivate];
	
	[xmppStream disconnect];
	
	xmppStream = nil;
	xmppReconnect = nil;
    xmppRoster = nil;
	xmppRosterStorage = nil;
	xmppvCardStorage = nil;
    xmppvCardTempModule = nil;
	xmppvCardAvatarModule = nil;
	xmppCapabilities = nil;
	xmppCapabilitiesStorage = nil;
}

-(BOOL)authenticate
{
    if ([xmppStream isDisconnected]) {
        NSLog(@"未连接成功！！");
        return NO;
    }
        NSString *myJID = [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyJID];
        NSString *myPassword = [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyPassword];
        
        NSLog(@"%@",myJID);
        //
        // If you don't want to use the Settings view to set the JID,
        // uncomment the section below to hard code a JID and password.
        //
        // myJID = @"user@gmail.com/xmppframework";
        // myPassword = @"";
        
        if (myJID == nil || myPassword == nil) {
            return NO;
        }
        
        myJID = [NSString stringWithFormat:@"%@@%@",myJID,@"124.205.147.26"];
        
        
        XMPPJID *jid = [XMPPJID jidWithString:myJID resource:@"XMPP"];
        [xmppStream setMyJID:jid];
        password = myPassword;
        
        NSError *error = nil;
        if (![xmppStream authenticateWithPassword:password error:&error])
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting"
                                                                message:@"See console for error details."
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];
            NSLog(@"%@",@"error authenticate!1");
            
            return NO;
        }
        return YES;
 

}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - button tapped methods
- (IBAction)sendAttechment:(id)sender {
    NSXMLElement *value1 = [NSXMLElement elementWithName:@"value" stringValue:@"http://jabber.org/protocol/bytestreams"];
    NSXMLElement *value2 = [NSXMLElement elementWithName:@"value" stringValue:@"http://jabber.org/protocol/ibb"];
    NSXMLElement *option1 = [NSXMLElement elementWithName:@"option"];
    [option1 addChild:value1];
    NSXMLElement *option2 = [NSXMLElement elementWithName:@"option"];
    [option2 addChild:value2];
    NSXMLElement *field = [NSXMLElement elementWithName:@"field"];
    [field addAttributeWithName:@"var" stringValue:@"stream-method"];
    [field addAttributeWithName:@"type" stringValue:@"list-single"];
    [field addChild:option1];
    [field addChild:option2];
    NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:data"];
    [x addAttributeWithName:@"type" stringValue:@"form"];
    [x addChild:field];
    NSXMLElement *feature = [NSXMLElement elementWithName:@"feature" xmlns:@"http://jabber.org/protocol/feature-neg"];
    [feature addChild:x];
    NSXMLElement *desc = [NSXMLElement elementWithName:@"desc" stringValue:@"send"];
    NSXMLElement *file = [NSXMLElement elementWithName:@"file" xmlns:@"http://jabber.org/protocol/si/profile/file-transfer"];
    [file addAttributeWithName:@"name" stringValue:@"camer.tex"];
    [file addAttributeWithName:@"size" stringValue:@"888"];
    [file addChild:desc];
    NSXMLElement *si = [NSXMLElement elementWithName:@"si" xmlns:@"http://jabber.org/protocol/si"];
    [si addAttributeWithName:@"profile" stringValue:@"http://jabber.org/protocol/si/profile/file-transfer"];
    [si addAttributeWithName:@"mime-type" stringValue:@"text/plain"];
    [si addAttributeWithName:@"id" stringValue:@"82B0C697-C1DE-93F9-103E-481C8E7A3BD8"];
    [si addChild:feature];
    [si addChild:file];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@%@/XMPP",self.toTextField.text,@"124.205.147.26"]];//
    [iq addAttributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@@124.205.147.26",self.userNameTextField.text]];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"iq_13"];
    [iq addChild:si];
    [self.xmppStream sendElement:iq];
    
    
}

- (IBAction)connectXMPP:(id)sender {
    [self connect];
}

- (IBAction)sendMessage:(id)sender {
    NSXMLElement *xmlBody = [NSXMLElement elementWithName:@"body"];
    [xmlBody setStringValue:self.messageTextField.text];
    NSXMLElement *xmlMessage = [NSXMLElement elementWithName:@"message"];
    [xmlMessage addAttributeWithName:@"type" stringValue:@"chat"];
    [xmlMessage addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@124.205.147.26",self.toTextField.text]];
    [xmlMessage addChild:xmlBody];
    [self.xmppStream sendElement:xmlMessage];
    
    //    [XMPPManager instence].toSomeOne = self.toTextField.text;
    //    NSMutableDictionary *msgAsDictionary = [[NSMutableDictionary alloc] init];
    //    [msgAsDictionary setObject:self.messageTextField.text forKey:@"message"];
    //    [msgAsDictionary setObject:@"you" forKey:@"sender"];
    //    [self.messages addObject:msgAsDictionary];
    NSLog(@"From: You, Message: %@", self.messageTextField.text);
    
}

-(void)sendMyMessage:(NSXMLElement *)message
{
    
    [self.xmppStream sendElement:message];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Core Data
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSManagedObjectContext *)managedObjectContext_roster
{
	return [xmppRosterStorage mainThreadManagedObjectContext];
}

- (NSManagedObjectContext *)managedObjectContext_capabilities
{
	return [xmppCapabilitiesStorage mainThreadManagedObjectContext];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)xmppStreamDidRegister:(XMPPStream *)sender
{
    NSLog(@"xmppStreamDidRegister");
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    //    registerSuccess = YES;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"创建帐号成功" message:@"创建成功！" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
    [self.delegate leaveRegister];
}
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error {
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"创建帐号失败" message:@"用户名冲突" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
}
- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    NSLog(@"socketDidConnect");
}


- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
    NSLog(@"willSecureWithSettings");
	if (allowSelfSignedCertificates)
	{
		[settings setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
	}
	
	if (allowSSLHostNameMismatch)
	{
		[settings setObject:[NSNull null] forKey:(NSString *)kCFStreamSSLPeerName];
	}
	else
	{
		// Google does things incorrectly (does not conform to RFC).
		// Because so many people ask questions about this (assume xmpp framework is broken),
		// I've explicitly added code that shows how other xmpp clients "do the right thing"
		// when connecting to a google server (gmail, or google apps for domains).
		
		NSString *expectedCertName = nil;
		
		NSString *serverDomain = xmppStream.hostName;
		NSString *virtualDomain = [xmppStream.myJID domain];
		
		if ([serverDomain isEqualToString:@"talk.google.com"])
		{
			if ([virtualDomain isEqualToString:@"gmail.com"])
			{
				expectedCertName = virtualDomain;
			}
			else
			{
				expectedCertName = serverDomain;
			}
		}
		else if (serverDomain == nil)
		{
			expectedCertName = virtualDomain;
		}
		else
		{
			expectedCertName = serverDomain;
		}
		
		if (expectedCertName)
		{
			[settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
		}
	}
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
    NSLog(@"xmppStreamDidSecure");
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSLog(@"xmppStreamDidConnect");
	isXmppConnected = YES;
	
	NSError *error = nil;
    if (isRegister == YES) {
        [self _registerNow];
        isRegister = NO;
        return;
    }
	
	if (![[self xmppStream] authenticateWithPassword:password error:&error])
	{
        NSLog(@"Error authenticating: %@", error);
	}
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
	NSLog(@"xmppStreamDidAuthenticate");
    [self.delegate authenticateSuccessed];
	[self goOnline];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    NSLog(@"didNotAuthenticate : %@",error);
    [self.delegate authenticateFailed];
}
- (void)xmppStream:(XMPPStream *)sender didSendIQ:(XMPPIQ *)iq
{
    NSLog(@"didSendIQ ----------%@",iq.description);
}
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
	NSLog(@"didReceiveIQ :++++++++++ %@",iq.description);
    //  #if !TARGET_IPHONE_SIMULATOR
    //	{
    //        NSMutableString *senderJID = [[NSMutableString alloc]init];
    //        NSMutableString *recieverJID = [[NSMutableString alloc] init];
    //
    //        if ([TURNSocket isNewStartTURNRequest:iq]) {
    //            NSLog(@"IS NEW TURN request Receive.. TURNSocket..................");
    //            TURNSocket *aturnSocket = [[TURNSocket alloc] initWithStream:xmppStream incomingTURNRequest:iq];
    //            [TURNSocket setProxyCandidates:[NSArray arrayWithObjects:@"saas.kanyabao.coms", nil]];//,@"proxy.saas.kanyabao.com",@"123.126.92.67"
    //            [aturnSocket startWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    //        }
    //
    //        if ([self isSetAskToTransfer:iq sender:senderJID reciever:recieverJID])[self sendAcceptIQRe:senderJID];
    //        return YES;
    //	}
    //#endif
    //    [self isResultAcceptOK:iq];
    
    
    //    [self getVisibleProxyAndSendToProxyToGetHost:iq];
    //    [self getHostAndPort:iq AndSend:senderJID ToReciever:recieverJID];
    //    [self getStreamhostUsedAndActivate:iq];
    
    if ([@"result" isEqualToString:iq.type]) {
        NSXMLElement *query = iq.childElement;
        if ([@"query" isEqualToString:query.name]) {
            NSArray *items = [query children];
            for (NSXMLElement *item in items) {
                NSString *jid = [item attributeStringValueForName:@"jid"];
                XMPPJID *xmppJID = [XMPPJID jidWithString:jid];
                [self.roster addObject:jid];
            }
        }
    }
    NSLog(@"%@",self.roster);
    [self.delegate reloadTableView];
	return YES;
}
//====================================================================================================================
- (BOOL)isSetAskToTransfer:(XMPPIQ *)iq sender:(NSMutableString *)senderJID reciever:(NSMutableString *)recieverJID{
    if ([iq isSetIQ]) {
        NSXMLElement *element = iq.childElement;
        if ([element.name isEqualToString:@"si"]) {
            [senderJID setString:iq.fromStr];
            [recieverJID setString:iq.toStr];
            
            return YES;
        }
    }
    return NO;
}
- (void)sendAcceptIQRe:(NSString *)reciever{
    NSXMLElement *value = [NSXMLElement elementWithName:@"value"];
    [value setStringValue:@"http://jabber.org/protocol/bytestreams"];
    NSXMLElement *value2 = [NSXMLElement elementWithName:@"value"];
    [value2 setStringValue:@"http://jabber.org/protocol/ibb"];
    NSXMLElement *field = [NSXMLElement elementWithName:@"field"];
    [field addAttributeWithName:@"var" stringValue:@"stream-method"];
    [field addChild:value];
    [field addChild:value2];
    NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:data"];
    [x addAttributeWithName:@"type" stringValue:@"submit"];
    [x addChild:field];
    NSXMLElement *feature = [NSXMLElement elementWithName:@"feature" xmlns:@"http://jabber.org/protocol/feature-neg"];
    [feature addChild:x];
    NSXMLElement *si = [NSXMLElement elementWithName:@"si" xmlns:@"http://jabber.org/protocol/si"];
    [si addChild:feature];
    NSXMLElement *sendIQ = [NSXMLElement elementWithName:@"iq"];
    [sendIQ addAttributeWithName:@"type" stringValue:@"result"];
    [sendIQ addAttributeWithName:@"to" stringValue:reciever];
    [sendIQ addChild:si];
    [self.xmppStream sendElement:sendIQ];
}
- (BOOL)isResultAcceptOK:(XMPPIQ *)iq{
    if ([iq isResultIQ]) {
        NSXMLElement *element = iq.childElement;
        if ([@"si" isEqualToString:element.name]) {
            if (element.children.count>0) {
                NSXMLElement *feature = [element.children objectAtIndex:0];
                if (feature.children.count>0) {
                    NSXMLElement *x = [feature.children objectAtIndex:0];
                    if ([x.name isEqualToString:@"x"]) {
                        NSDictionary *dic = x.attributesAsDictionary;
                        if ([[dic objectForKey:@"type"] isEqualToString:@"submit"]) {
                            //receiver say ok
                            //进入XEP-0065协议阶段
                            //初始方给服务器发送信息，请求提供代理服务器
                            
                            XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@/XMPP",self.toTextField.text,self.hostTextField.text]];
                            [TURNSocket setProxyCandidates:[NSArray arrayWithObjects:@"124.205.147.26", nil]];
                            turnSocket = [[TURNSocket alloc] initWithStream:xmppStream toJID:jid];
                            [turnSocket startWithDelegate:self delegateQueue:dispatch_get_main_queue()];
                            
                            //                            NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/disco#items"];
                            //                            NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
                            //                            [iq addAttributeWithName:@"id" stringValue:@"iq_15"];
                            //                            [iq addAttributeWithName:@"type" stringValue:@"get"];
                            //                            [iq addChild:query];
                            //                            [self.xmppStream sendElement:iq];
                        }
                    }
                }
            }
        }
    }
    return NO;
}
- (void)getVisibleProxyAndSendToProxyToGetHost:(XMPPIQ *)iq{
    if ([iq isResultIQ]) {
        NSXMLElement *element = iq.childElement;
        if ([@"query" isEqualToString:element.name]) {
            NSArray *items = [element children];
            for (NSXMLElement *item in items) {
                if ([item.name isEqualToString:@"item"]) {
                    NSString *name = [item attributeStringValueForName:@"name"];
                    if ([name isEqualToString:@"Socks 5 Bytestreams Proxy"]) {
                        //初始方给这个代理发送信息获取代理连接信息
                        NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/bytestreams"];
                        NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
                        [iq addAttributeWithName:@"id" stringValue:@"iq_19"];
                        [iq addAttributeWithName:@"to" stringValue:[item attributeStringValueForName:@"jid"]];
                        [iq addAttributeWithName:@"type" stringValue:@"get"];
                        [iq addChild:query];
                        [self.xmppStream sendElement:iq];
                    }
                }
            }
        }
    }
}
- (void)getHostAndPort:(XMPPIQ *)iq AndSend:(NSString *)sender ToReciever:(NSString *)reciever{
    if ([iq isResultIQ]) {
        NSXMLElement *element = iq.childElement;
        if ([@"query" isEqualToString:element.name]) {
            NSString *host ;
            NSString *port ;
            NSString *pjid;
            NSArray *items = [element children];
            for (NSXMLElement *item in items) {
                if ([item.name isEqualToString:@"streamhost"]) {
                    host = [item attributeStringValueForName:@"host"];
                    port = [item attributeStringValueForName:@"port"];
                    pjid = [item attributeStringValueForName:@"jid"];
                    proxyPort = port;
                    proxyHost = host;
                    proxyJID = pjid;
                    //初始方收到代理信息后将代理的信息发送给目标方
                    NSXMLElement *streamhost = [NSXMLElement elementWithName:@"streamhost"];
                    [streamhost addAttributeWithName:@"port" stringValue:port];
                    [streamhost addAttributeWithName:@"host" stringValue:@"124.205.147.26"];//123.126.92.67
                    [streamhost addAttributeWithName:@"jid" stringValue:host];
                    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/bytestreams"];
                    [query addAttributeWithName:@"mode" stringValue:@"tcp"];
                    [query addAttributeWithName:@"sid" stringValue:@"82B0C697-C1DE-93F9-103E-481C8E7A3BD8"];
                    [query addChild:streamhost];
                    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
                    [iq addAttributeWithName:@"to" stringValue:@"wangdf@saas.kanyabao.com/Spark 2.6.3"];
                    [iq addAttributeWithName:@"type" stringValue:@"set"];
                    [iq addAttributeWithName:@"id" stringValue:@"iq_19"];
                    [iq addAttributeWithName:@"from" stringValue:@"abc@saas.kanyabao.com/XMPP"];
                    [iq addChild:query];
                    [self.xmppStream sendElement:iq];
                }
                
            }
        }
    }
}
- (void)getStreamhostUsedAndActivate:(XMPPIQ *)iq{
    if ([iq isResultIQ]) {
        NSXMLElement *element = iq.childElement;
        if ([@"query" isEqualToString:element.name]) {
            NSArray *items = [element children];
            for (NSXMLElement *item in items) {
                if ([item.name isEqualToString:@"streamhost-used"]) {
                    //                    NSString *streamhostused = [item attributeStringValueForName:@"jid"];
                    NSError *error ;
                    
                    GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
                    //                    [self.xmppStream connectP2PWithSocket:socket error:&error];
                    //                    NSLog(@"error : %@",error);
                    if ([socket connectToHost:@"124.205.147.26" onPort:5222 error:&error]) {
                    }else{
                        if (error) {
                            NSLog(@"socke error : %@",error);
                        }
                    }
                }
            }
        }
    }
}
//=======================================================================================================================

//- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
//{
//
//    NSLog(@"didConnectToHost : %@ :%d",host,port);
//
////    int a[3] = {5,1,0};
////    NSData *data = [[NSData alloc] initWithBytes:a length:3];
////    NSLog(@"data; %@",data);
//    [sock writeData:[@"5,1,0" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
//    [sock readDataWithTimeout:-1 tag:0];
//
////    NSXMLElement *activate = [NSXMLElement elementWithName:@"activate" stringValue:@"wangdf@saas.kanyabao.com/Spark 2.6.3"];
////    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/bytestreams"];
////    [query addAttributeWithName:@"sid" stringValue:@"82B0C697-C1DE-93F9-103E-481C8E7A3BD8"];
////    [query addChild:activate];
////    NSXMLElement *iqsend = [NSXMLElement elementWithName:@"iq"];
////    [iqsend addAttributeWithName:@"to" stringValue:@"proxy.saas.kanyabao.com"];
////    [iqsend addAttributeWithName:@"type" stringValue:@"set"];
////    [iqsend addAttributeWithName:@"id" stringValue:@"iq_21"];
////    [iqsend addAttributeWithName:@"from" stringValue:@"abc@saas.kanyabao.com/XMPP"];
////    [iqsend addChild:query];
////    [self.xmppStream sendElement:iqsend];
//
//
//}
//- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
//{
//    NSLog(@"didWriteDataWithTag");
////    [sock readDataWithTimeout:30 tag:0];
////    NSData *data = [[NSData alloc]init];
////    NSMutableData *mData = [[NSMutableData alloc]init];
////    [sock readDataToData:data withTimeout:30 buffer:mData bufferOffset:5 tag:0];
////    [sock readDataWithTimeout:30 buffer:mData bufferOffset:5 tag:0];
//
//}
//- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
//{
//    NSLog(@"didReadData : %@",data);
//}
//- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
//{
//    NSLog(@"socketDidDisconnect error : %@",err);
//
//
//}
//=======================================================================================================================
- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message
{
    NSLog(@"did send message : %@",message.description);
    [self saveHistory:message];
}
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    NSLog(@"didReceiveMessage ： %@",message.description);
	// A simple example of inbound message handling.
    
    //    [self.delegate showMessage:message];
	if ([message isChatMessageWithBody])
	{
		XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[message from]
		                                                         xmppStream:xmppStream
		                                               managedObjectContext:[self managedObjectContext_roster]];
		
		NSString *body = [[message elementForName:@"body"] stringValue];
		NSString *displayName = [user displayName];
        if ([message isOfflineMessageWithBody]) {
            
        }
        
        
        if ([body base64DecodedData]) {
            NSData *data = [body base64DecodedData];
            NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/test.amr"];
            NSLog(@"path : %@",path);
            BOOL write = [data writeToFile:path atomically:YES];
            if (write) {
                NSLog(@"yes");
            }else{
                NSLog(@"no");
            }
        }
        
		if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
		{
//			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
//                                                                message:body
//                                                               delegate:nil
//                                                      cancelButtonTitle:@"Ok"
//                                                      otherButtonTitles:nil];
//			[alertView show];
		}
		else
		{
			// We are not active, so use a local notification instead
			UILocalNotification *localNotification = [[UILocalNotification alloc] init];
			localNotification.alertAction = @"Ok";
			localNotification.alertBody = [NSString stringWithFormat:@"From: %@\n\n%@",displayName,body];
            
			[[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
		}
	}
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    //    NSLog(@"didReceivePresence : %@",presence.description);
    //    if (![presence.type isEqualToString:@"error"]) {
    //        self.jidWithResouce = presence.fromStr;
    //    }
    //    NSLog(@"jidWithResouce : %@",jidWithResouce);
    if ([presence.type isEqualToString:@"subscribe"]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:presence.fromStr message:@"add" delegate:self cancelButtonTitle:@"cancle" otherButtonTitles:@"yes", nil];
        alertView.tag = tag_subcribe_alertView;
        [alertView show];
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
    NSLog(@"didReceiveError");
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    NSLog(@"xmppStreamDidDisconnect");
	if (!isXmppConnected)
	{
        NSLog(@"Unable to connect to server. Check xmppStream.hostName");
	}
}
//- (NSString *)xmppStream:(XMPPStream *)sender alternativeResourceForConflictingResource:(NSString *)conflictingResource
//{
//    NSLog(@"alternativeResourceForConflictingResource : %@",conflictingResource);
//    return @"XMPP";
//}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPRosterDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence
{
	
	XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[presence from]
	                                                         xmppStream:xmppStream
	                                               managedObjectContext:[self managedObjectContext_roster]];
	
	NSString *displayName = [user displayName];
	NSString *jidStrBare = [presence fromStr];
	NSString *body = nil;
	NSLog(@"%@",displayName);
	if (![displayName isEqualToString:jidStrBare])
	{
		body = [NSString stringWithFormat:@"Buddy request from %@ <%@>", displayName, jidStrBare];
	}
	else
	{
		body = [NSString stringWithFormat:@"Buddy request from %@", displayName];
	}
	
	
	if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
		                                                    message:body
		                                                   delegate:nil
		                                          cancelButtonTitle:@"Not implemented"
		                                          otherButtonTitles:nil];
		[alertView show];
	}
	else
	{
		// We are not active, so use a local notification instead
		UILocalNotification *localNotification = [[UILocalNotification alloc] init];
		localNotification.alertAction = @"Not implemented";
		localNotification.alertBody = body;
		
		[[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
	}
	
}
-(void)xmppRosterDidPopulate:(XMPPRosterMemoryStorage *)sender {
    NSLog(@"users: %@", [sender unsortedUsers]);
    // My subscribed users do print out
}
#pragma mark -
#define tag_writeData 1000
#define tag_readData 1001
- (void)turnSocket:(TURNSocket *)sender didSucceed:(GCDAsyncSocket *)socket
{
    NSLog(@"TURNSocket   didSucceed");
    mySocket = socket;
    [mySocket setDelegate:self delegateQueue:dispatch_get_main_queue()];
#if !TARGET_IPHONE_SIMULATOR
	{
        NSData *dataF = [[NSData alloc] init];
        [socket readDataToData:dataF withTimeout:-1.0 tag:tag_readData];
        NSLog(@"dataF: %d", [dataF length]);
        return;
    }
#endif
    [socket writeData:[@"hello" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1.0 tag:tag_writeData];//[NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"camer" ofType:@"png"]]
    [socket readDataWithTimeout:-1 tag:tag_readData];
    [socket disconnectAfterWriting];
    
    
}
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"didWriteDataWithTag tag ; %ld",tag);
    //    [sock readDataWithTimeout:-1 tag:1001];
    
}
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"didReadData data : %@",data);
    
}
- (void)turnSocketDidFail:(TURNSocket *)sender
{
    NSLog(@"turnSocketDidFail-----%@",sender.description);
    
}
#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == tag_subcribe_alertView && buttonIndex == 1) {
        XMPPJID *jid = [XMPPJID jidWithString:alertView.title];
        [[self xmppRoster] acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
    }
}
#pragma mark - my method
-(void)showAlertView:(NSString *)message{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:message delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    [alertView show];
}


@end
