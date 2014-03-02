//
//  AppController.m
//  sshproxy
//
//  Created by Brant Young on 16/1/13.
//  Copyright (c) 2013 Codinn Studio. All rights reserved.
//
#import <ServiceManagement/ServiceManagement.h>
#import "AppController.h"
#import "GeneralPreferencesViewController.h"
#import "ServersPreferencesViewController.h"
#import "WhitelistPreferencesViewController.h"
#import "MASPreferencesWindowController.h"
#import "CSProxy.h"
#import "WhitelistHelper.h"

@implementation AppController {
    /* The other stuff :P */
    NSStatusItem *statusItem;
    NSImage *offStatusImage;
    NSImage *onStatusImage;
    NSImage *in1StatusImage;
    NSImage *in2StatusImage;
    
    NSTask *task;
    NSPipe *pipe;
    NSString* taskOutput;
    
    int proxyStatus;
    NSString *errorMsg;
    
	INSOCKSServer *_server;
    
    NSTimer *_rollImageTimer;
}

@synthesize preferencesWindowController;
@synthesize aboutWindowController;

static int sshProcessIdentifier;

-(id)init
{
    self = [super init];
    if (self){
        taskOutput = [[NSString alloc] init];
    }
    return self;
}


- (void) awakeFromNib
{
    [NSApp setMainMenu:self.mainMenu];
    
    //Create the NSStatusBar and set its length
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    
    //Allocates and loads the images into the application which will be used for our NSStatusItem
    offStatusImage = [NSImage imageNamed:@"disconnectedTemplate"];
    onStatusImage = [NSImage imageNamed:@"connectedTemplate"];
    in1StatusImage = [NSImage imageNamed:@"connecting1Template"];
    in2StatusImage = [NSImage imageNamed:@"connecting2Template"];
    
    //Sets the images in our NSStatusItem
    [statusItem setImage:offStatusImage];
    
    //Tells the NSStatusItem what action to active
    [statusItem setAction:@selector(statusItemClicked)];
    //Sets the tooptip for our item
    [statusItem setToolTip:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]];
    //Enables highlighting
    [statusItem setHighlightMode:YES];
    
    // upgrade
    [CSProxy upgrade1:self.serverArrayController];
    [CSProxy upgrade2:self.serverArrayController];
    
    // init menu text
    self.statusMenuItem.title = NSLocalizedString(@"sshproxy.mainmenu.proxy_off", nil);
    self.turnOffMenuItem.title = NSLocalizedString(@"sshproxy.mainmenu.turn_off", nil);
    self.turnOnMenuItem.title = NSLocalizedString(@"sshproxy.mainmenu.turn_on", nil);
    self.add2WhitelistMenuItem.title = NSLocalizedString(@"sshproxy.mainmenu.add_to_whitelist", nil);
    self.allSitesMenuItem.title = NSLocalizedString(@"sshproxy.mainmenu.use_proxy_for_all_sites", nil);
    self.onlyWhitelistMenuItem.title = NSLocalizedString(@"sshproxy.mainmenu.use_proxy_for_whitelist", nil);
    self.directConnectMenuItem.title = NSLocalizedString(@"sshproxy.mainmenu.direct_connection", nil);
    self.preferenceMenuItem.title = NSLocalizedString(@"sshproxy.mainmenu.preferences", nil);
    self.helpMenuItem.title = NSLocalizedString(@"sshproxy.mainmenu.help", nil);
    self.aboutMenuItem.title = NSLocalizedString(@"sshproxy.about.title", nil);
    self.quitMenuItem.title = NSLocalizedString(@"sshproxy.mainmenu.quit", nil);
    
    [self.cautionMenuItem setHidden:YES];
}

#pragma mark - Set status menu state

- (void)set2connect
{
    [self startRollImageTimer:self];
    self.statusMenuItem.title = NSLocalizedString(@"sshproxy.mainmenu.proxy_connecting", nil);
    
    [self setCautionMessage];
    
    [self.turnOnMenuItem setHidden:YES];
    [self.turnOffMenuItem setHidden:NO];
}

- (void)set2connected
{
    proxyStatus = SSHPROXY_CONNECTED;
    
    [self stopRollImageTimer:self];
    [statusItem setImage:onStatusImage];
    
    self.statusMenuItem.title = NSLocalizedString(@"sshproxy.mainmenu.proxy_on", nil);
    
    [self setCautionMessage];
    
    [self.turnOnMenuItem setHidden:YES];
    [self.turnOffMenuItem setHidden:NO];
}

- (void)set2disconnected
{
    [self stopRollImageTimer:self];
    [statusItem setImage:offStatusImage];
    
    self.statusMenuItem.title = NSLocalizedString(@"sshproxy.mainmenu.proxy_off", nil);
    
    [self setCautionMessage];
    
    [self.turnOffMenuItem setHidden:YES];
    [self.turnOnMenuItem setHidden:NO];
}

- (void)setCautionMessage
{
    if (errorMsg) {
        [self.cautionMenuItem setTitle:errorMsg];
        [self.cautionMenuItem setHidden:NO];
    } else {
        [self.cautionMenuItem setHidden:YES];
    }
}

- (void)set2reconnect
{
    [self startRollImageTimer:self];
    self.statusMenuItem.title = NSLocalizedString(@"sshproxy.mainmenu.proxy_reconnecting", nil);
    
    [self setCautionMessage];
    
    [self.turnOffMenuItem setHidden:NO];
    [self.turnOnMenuItem setHidden:YES];
}

#pragma mark - Actions

- (void)statusItemClicked
{
    NSMenu* menu = [self.statusMenu copy];
    menu.minimumWidth = 256.0;
    
    NSArray* servers = [CSProxy getProxyServers];
    NSInteger activatedServerIndex = [CSProxy getActivatedServerIndex];
    
    if (servers && servers.count>0) {
        //        [menu insertItemWithTitle:@"Servers:" action:nil keyEquivalent:@"" atIndex:4];
        
        int i = 0;
        for (CSProxy* server in servers) {
            NSMenuItem* item = [NSMenuItem alloc];
            item.title = [NSString stringWithFormat:@" %@@%@", server.ssh_user, server.ssh_host];
            item.action = @selector(switchServer:);
            item.indentationLevel = 1;
            
            item.representedObject = @(i);
            
            if (i==activatedServerIndex) {
                [item setState:NSOnState];
            }
            
            [menu insertItem:item atIndex:5+i];
            i++;
        }
        
        [menu insertItem:[NSMenuItem separatorItem] atIndex:5+i];
    }
    
    [statusItem popUpStatusItemMenu:menu];
}


- (void)switchServer:(id)sender
{
    NSMenuItem* menuItem = (NSMenuItem*)sender;
    
    int index = [(NSNumber*)menuItem.representedObject intValue];
    [CSProxy setActivatedServer:index];
    
    [self _turnOffProxy];
    [self performSelector: @selector(turnOnProxy:) withObject:self afterDelay: 0.0];
}

- (void)reactiveProxy:(id)sender
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // if turnOffMenuItem current state is visible and enabled, then reactive proxy
    if ( !self.turnOffMenuItem.isHidden) {
        [self stopServer];
        
        [self set2reconnect];
        [self turnOffProxy:sender];
        [self _turnOnProxy];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    BOOL disableAutoconnect = [[NSUserDefaults standardUserDefaults] boolForKey:@"disable_autoconnect"];
    BOOL autoLaunch = [[NSUserDefaults standardUserDefaults] boolForKey:@"auto_launch"];
    
    if (! disableAutoconnect) {
        proxyStatus = SSHPROXY_INIT;
        [self set2connect];
        [self performSelector: @selector(_turnOnProxy) withObject:nil afterDelay: 0.0];
    }
    
    if (autoLaunch) {
        // reenable
        SMLoginItemSetEnabled ((__bridge CFStringRef)@"com.codinnstudio.sshproxyhelper", YES);
    } else {
        SMLoginItemSetEnabled ((__bridge CFStringRef)@"com.codinnstudio.sshproxyhelper", NO);
    }
}

- (IBAction)turnOnProxy:(id)sender
{
    proxyStatus = SSHPROXY_ON;
    
    errorMsg = nil;
    [self set2connect];
    
    [self _turnOnProxy];
}

- (void)_turnOnProxy
{
    NSError *error = [self startServer];
    if (error) {
        // failed to establish internal socks server
        return;
    }
    
    if (task) {
        // task already running, do noting
        return;
    }
    
    CSProxy* server = [CSProxy getActivatedServer];
    
    // open preferences window if remoteHost is empty
    if (!server) {
        [self openServersPreferences];
        errorMsg = nil;
        [self set2disconnected];
        return;
    }
    
    NSString* remoteHost = server.ssh_host;
    NSString* loginName = server.ssh_user;
    int remotePort = server.ssh_port;
    NSInteger localPort = [CSProxy getSSHLocalPort];
    BOOL enableCompression = server.enable_compression.boolValue;
    
    // Get the path of our Askpass program, which we've included as part of the main application bundle
    NSString *askPassPath = [NSBundle pathForResource:@"SSH Proxy - Ask Password" ofType:@""
                                          inDirectory:[[NSBundle mainBundle] bundlePath]];
    
    
    NSString *encryptedServerInfo = [CSProxy encryptServerInfo:server];
    
    // This creates a dictionary of environment variables (keys) and their values (objects) to be set in the environment where the task will be run. This environment dictionary will then be accessible to our Askpass program.

    NSMutableDictionary *env = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                NSHomeDirectory(), @"HOME",
                                @":9999", @"DISPLAY",
                                askPassPath, @"SSH_ASKPASS",
                                encryptedServerInfo, @"SSHPROXY_SERVER_INFO",
                                @"1",@"INTERACTION",
                                NSHomeDirectory(), @"SSHPROXY_USER_HOME",
                                nil];
    [env addEntriesFromDictionary:server.getProxyCommandEnv];
    
    NSMutableString* advancedOptions = [NSMutableString stringWithString:@"-"];
//    if (shareSocks==NSOnState) {
//        [advancedOptions appendString:@"g"];
//    }
    if (enableCompression) {
        [advancedOptions appendString:@"C"];
    }
    [advancedOptions appendString:@"ND"];
    
    //    DLog(@"Environment dict %@",env);
    NSMutableArray *arguments = nil;
    BOOL isPublicKeyMode = server.auth_method.integerValue==CSSSHAuthMethodPublicKey;

    if ( isPublicKeyMode ) {
        arguments = [server getPublicKeyMethodConnectArgs];
    } else {
        arguments = [server getPasswordMethodConnectArgs];
    }
    
    if (!arguments) {
        // abort connection
        errorMsg = NSLocalizedString(@"sshproxy.errmsg.invalid_auth", nil);
        [self set2disconnected];
        return;
    }
    
    NSString *proxyCommandStr = server.getProxyCommandStr;
    
    if (proxyCommandStr) {
        [arguments addObject:proxyCommandStr];
    }
    
    [arguments addObjectsFromArray:@[
                                     advancedOptions,
                                     [NSString stringWithFormat:@"%@", @(localPort)],
                                     [NSString stringWithFormat:@"%@@%@", loginName, remoteHost],
                                     @"-p",
                                     [NSString stringWithFormat:@"%d", remotePort]
                                ]
     ];
    
    // TODO: CATCH TASK EXCEPTION
    
    task = [[NSTask alloc] init];
    
    [env addEntriesFromDictionary:[[NSProcessInfo processInfo] environment]];
    
    [task setEnvironment:env];
    [task setArguments:arguments];
    
    [task setLaunchPath:@"/usr/bin/ssh"];
    
    // Setup the pipes on the task
    pipe = [[NSPipe alloc] init];
    //        errorPipe = [[NSPipe alloc] init];
    [task setStandardOutput:pipe];
    [task setStandardError:pipe];
    // It's important that we set the standard input to null here. This is sometimes required in order to get SSH to use our Askpass program rather then prompt the user interactively.
    [task setStandardInput:[NSFileHandle fileHandleWithNullDevice]];
    
    // clear taskOutput buffer
    taskOutput = [[NSString alloc] init];
    
    NSFileHandle *fh = [pipe fileHandleForReading];
    [fh waitForDataInBackgroundAndNotify];
    
    NSNotificationCenter *nc;
    nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
    [nc addObserver:self
           selector:@selector(dataReady:) name:NSFileHandleDataAvailableNotification
             object:fh];
    [nc addObserver:self
           selector:@selector(taskTerminated:) name:NSTaskDidTerminateNotification
             object:task];
    
    // delete askpass lock file
    NSString* lockFile= [NSHomeDirectory() stringByAppendingPathComponent:OW_SSHPROXY_ASKPASS_LOCK];
    [[NSFileManager defaultManager] removeItemAtPath:lockFile error:nil];
    
    [task launch];
    
    sshProcessIdentifier = task.processIdentifier;
}

- (void)reconnectIfNeed:(NSString*) state
{
    if (proxyStatus==SSHPROXY_CONNECTED || proxyStatus==SSHPROXY_INIT) {
        errorMsg = state;
        [self set2reconnect];
        [self performSelector: @selector(_turnOnProxy) withObject:nil afterDelay: 3.0];
    } else {
        if (proxyStatus==SSHPROXY_OFF) { // turn off manually
            errorMsg = nil;
        } else { // by error
            errorMsg = state;
        }
        
        [self set2disconnected];
    }
}

- (void)dataReady:(NSNotification *)n
{
    NSFileHandle *fh = [n object];
    NSData *data = [fh availableData];
    
    // only receive data when proxy 
    NSString *s = [[NSString alloc] initWithData:data
                                        encoding:NSUTF8StringEncoding];
    
    // truncate task output to reduce memory consume
    NSInteger fromIndex = [taskOutput length]-256;
    fromIndex = fromIndex > 0 ? fromIndex : 0;
    
    taskOutput = [taskOutput substringFromIndex:fromIndex];
    taskOutput = [taskOutput stringByAppendingString:s];
    DDLogInfo(@"%@",s);
    
    // If the task is running, start reading again
    if (task) {
        if ( [taskOutput rangeOfString:@"Entering interactive session"].location != NSNotFound){
            errorMsg = nil;
            [self set2connected];
        }
        
        [fh waitForDataInBackgroundAndNotify];
    } else {
        if ([taskOutput rangeOfString:@"bind: Address already in use"].location != NSNotFound) {
            errorMsg = NSLocalizedString(@"sshproxy.errmsg.sshport", nil);
            [self set2disconnected];
            return;
        } else if ([taskOutput rangeOfString:@"Permission denied "].location != NSNotFound) {
            CSProxy *server = [CSProxy getActivatedServer];
            BOOL isPublicKeyMode = server.auth_method.integerValue==CSSSHAuthMethodPublicKey;

            if (isPublicKeyMode) {
                errorMsg = NSLocalizedString(@"sshproxy.errmsg.pubkey", nil);
            } else {
                errorMsg = NSLocalizedString(@"sshproxy.errmsg.password", nil);
            }
            [self set2disconnected];
            return;
        } else {
            NSArray* errors = @[
                                @[@"ssh: Could not resolve hostname"   , NSLocalizedString(@"sshproxy.errmsg.hostname", nil)],
                                
                                @[@"Connection refused"                , NSLocalizedString(@"sshproxy.errmsg.refused", nil)],
                                
                                @[@"Timeout,"                          , NSLocalizedString(@"sshproxy.errmsg.timeout", nil)],
                                
                                @[@"Connection timed out during banner exchange" , NSLocalizedString(@"sshproxy.errmsg.timedout", nil)],
                                
                                @[@"timed out"                         , NSLocalizedString(@"sshproxy.errmsg.timedout2", nil)],
                                
                                @[@"Write failed: Broken pipe"         , NSLocalizedString(@"sshproxy.errmsg.disconnected", nil)],
                                
                                @[@"Connection closed by remote host"  , NSLocalizedString(@"sshproxy.errmsg.failed", nil)],
                                
                                @[@"unknown error"                     , NSLocalizedString(@"sshproxy.errmsg.unknown", nil)],
                                ];
            for (NSArray* error in errors) {
                if ( ([taskOutput rangeOfString:error[0]].location != NSNotFound) || [error[0] isEqual:@"unknown error"]) {
                    [self reconnectIfNeed:error[1]];
                    break;
                }
            }
        }
    }
}
// When the process is done, we should do some cleanup:
- (void)taskTerminated:(NSNotification *)note
{
    [AppController initSshProcessIdentifier];
    
    task = nil;

    errorMsg = nil;
    [self set2disconnected];
}


- (IBAction)turnOffProxy:(id)sender
{
    proxyStatus = SSHPROXY_OFF;
    [self _turnOffProxy];
}


- (void)_turnOffProxy
{
    DDLogInfo(@"Turn off proxy: %@", taskOutput);
    
    // clear taskOutput buffer
    taskOutput = [[NSString alloc] init];
    
    if (!task) {
        // dead task , do noting
        return;
    }
    
    [task interrupt];
//    [task waitUntilExit];
    task = nil;
}


- (NSWindowController *)preferencesWindowController
{
    if (!preferencesWindowController)
    {
        NSViewController *generalViewController = [[GeneralPreferencesViewController alloc] init];
        NSViewController *serversViewController = [[ServersPreferencesViewController alloc] init];
        NSViewController *whitelistViewController = [[WhitelistPreferencesViewController alloc] init];
        NSArray *controllers = @[generalViewController, serversViewController, whitelistViewController];
        
        // To add a flexible space between General and Advanced preference panes insert [NSNull null]:
        //     NSArray *controllers = [[NSArray alloc] initWithObjects:generalViewController, [NSNull null], advancedViewController, nil];
        
        NSString *title = NSLocalizedString(@"sshproxy.pref.title", nil);
        preferencesWindowController = [[MASPreferencesWindowController alloc] initWithViewControllers:controllers title:title delegate:self];
        
        [preferencesWindowController.window setReleasedWhenClosed: NO];
        [[preferencesWindowController.window standardWindowButton:NSWindowZoomButton] setEnabled:NO];
//        preferencesWindowController.window.level = NSFloatingWindowLevel;
    }
    return preferencesWindowController;
}

- (AboutWindowController *)aboutWindowController
{
    if (!aboutWindowController)
    {
        aboutWindowController = [[AboutWindowController alloc] init];
    }
    return aboutWindowController;
}

- (IBAction)openPreferences:(id)sender
{
    [NSApp activateIgnoringOtherApps:YES];
    [[self.preferencesWindowController window] makeKeyAndOrderFront:nil];
    [[self.preferencesWindowController window] setLevel:NSFloatingWindowLevel];
    [[self.preferencesWindowController window] setCollectionBehavior: NSWindowCollectionBehaviorCanJoinAllSpaces];
//    [[self.preferencesWindowController window] center];
    [self.preferencesWindowController showWindow:nil];
}

- (void)openServersPreferences
{
    [self.preferencesWindowController selectControllerAtIndex:1];
    [self performSelector: @selector(openPreferences:) withObject:self afterDelay: 0.0];
}

- (IBAction)openWhitelistPreferences:(id)sender
{
    [self.preferencesWindowController selectControllerAtIndex:2];
    [self performSelector: @selector(openPreferences:) withObject:sender afterDelay: 0.0];
    
    WhitelistPreferencesViewController *viewController = (WhitelistPreferencesViewController *)self.preferencesWindowController.selectedViewController;
    
    [viewController performSelector: @selector(addSite:) withObject:sender afterDelay: 0.2];
}

- (IBAction)openAboutWindow:(id)sender
{
    [NSApp activateIgnoringOtherApps:YES];
    
    [self.aboutWindowController.window makeKeyAndOrderFront:nil];
    [self.aboutWindowController.window setCollectionBehavior: NSWindowCollectionBehaviorCanJoinAllSpaces];
    [self.aboutWindowController.window center];
    [self.aboutWindowController.window setLevel:NSFloatingWindowLevel];
    
    [self.aboutWindowController showWindow:nil];
}

- (IBAction)openHelpURL:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:
     [NSURL URLWithString:@"https://github.com/brantyoung/sshproxy/wiki"]];
}

- (IBAction)switchProxyMode:(id)sender
{
    NSMenuItem* menuItem = (NSMenuItem*)sender;
    
    [WhitelistHelper setProxyMode:menuItem.tag];
}

#pragma mark - MASPreferencesWindowDelegate

- (void)preferencesWindowWillClose:(NSNotification *)notification
{
    self.preferencesWindowController = nil;
}

#pragma mark - NSApplicationDelegate

-(NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    [task interrupt];
    [self stopServer];
    return NSTerminateNow;
}

#pragma mark - Connecting images roll
- (IBAction)startRollImageTimer:(id)sender
{
    if (_rollImageTimer == nil) {
        _rollImageTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f
                                                  target:self
                                                selector:@selector(rollConnectingImage)
                                                userInfo:nil
                                                 repeats:YES];
    }
}

- (IBAction)stopRollImageTimer:(id)sender
{
    if (_rollImageTimer != nil) {
        [_rollImageTimer invalidate];
        _rollImageTimer = nil;
    }
}

- (void)rollConnectingImage
{
    if (statusItem.image == in1StatusImage) {
        statusItem.image = in2StatusImage;
    } else {
        statusItem.image = in1StatusImage;
    }
}

#pragma mark - SOCKS server control

- (NSError *)startServer
{
	if (_server) return nil;
    
	NSError *error = nil;
    
    BOOL shareSocks = [CSProxy isShareSOCKS];
    
    if (shareSocks) {
        _server = [[INSOCKSServer alloc] initWithPort:[CSProxy getLocalPort] error:&error];
    } else {
        _server = [[INSOCKSServer alloc] initWithInterface:@"127.0.0.1" port:[CSProxy getLocalPort] error:&error];
    }
    
	_server.delegate = self;
    
	if (error) {
		DDLogInfo(@"Error starting server: %@, %@", error, error.userInfo);
        errorMsg = [NSString stringWithFormat:NSLocalizedString(@"sshproxy.errmsg.port", nil), @([CSProxy getLocalPort])];
        [self set2disconnected];
        [self stopServer];
	} else {
		DDLogInfo(@"SOCKS server on host %@ listening on port %d", _server.host, _server.port);
	}
    
    return error;
}

- (void)stopServer
{
	if (!_server) return;
    
    _server.delegate = nil;
	[_server disconnect];
	_server = nil;
}

//- (NSError *)restartServer
//{
//    [self stopServer];
//    
//	NSError *error = [self startServer];
//    
//	if (error) {
//        // retry
//        [self performSelector: @selector(restartServer) withObject:nil afterDelay: 1.0];
//	}
//    
//    return error;
//}


#pragma mark - INSOCKSServerDelegate

- (void)SOCKSServer:(INSOCKSServer *)server didAcceptConnection:(INSOCKSConnection *)connection
{
}

- (BOOL)SOCKSServer:(INSOCKSServer *)server shouldRelay:(INSOCKSConnection *)connection
{
    return [WhitelistHelper isHostShouldProxy:connection.targetHost];
}

- (NSArray *)SOCKSServerGetRelayAddress:(INSOCKSServer *)server
{
    return @[@"127.0.0.1", @([CSProxy getSSHLocalPort])];
}

+ (int)sshProcessIdentifier
{
    return sshProcessIdentifier;
}

+ (void)initSshProcessIdentifier
{
    sshProcessIdentifier = -100;
}

@end
