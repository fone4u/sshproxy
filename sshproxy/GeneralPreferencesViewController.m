//
//  PreferencesController
//  sshproxy
//
//  Created by Brant Young on 16/1/13.
//  Copyright (c) 2013 Codinn Studio. All rights reserved.
//
#import <ServiceManagement/ServiceManagement.h>

#import "GeneralPreferencesViewController.h"
#import "CharmNumberFormatter.h"
#import "CSProxy.h"
#import "AppController.h"

@implementation GeneralPreferencesViewController

#pragma mark - MASPreferencesViewController

- (id)init
{
    return [super initWithNibName:@"GeneralPreferencesView" bundle:nil];
}

- (NSString *)identifier
{
    return @"GeneralPreferences";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNamePreferencesGeneral]; // NSImageNameNetwork
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"sshproxy.pref.general.title", nil);
}

-(void)loadView
{
    [super loadView];
    
    CharmPortFormatter *formatter = [[CharmPortFormatter alloc] init];
    self.localPortTextField.formatter = formatter;
    
    NSInteger localPort = [CSProxy getLocalPort];
    
    self.localPortTextField.integerValue = localPort;
    self.localPortStepper.integerValue = localPort;
    
    self.socksBox.title = NSLocalizedString(@"sshproxy.pref.general.socksbox", nil);
    self.listeningTextField.stringValue = NSLocalizedString(@"sshproxy.pref.general.listening", nil);
    self.listeningRangeTextField.stringValue = NSLocalizedString(@"sshproxy.pref.general.listening_range", nil);
    self.shareButton.title = NSLocalizedString(@"sshproxy.pref.general.sharesocks", nil);
    self.autoConnectButton.title = NSLocalizedString(@"sshproxy.pref.general.auto_connect", nil);
    self.startAtLoginButton.title = NSLocalizedString(@"sshproxy.pref.general.start_at_login", nil);
}


#pragma mark - Actions

- (IBAction)localStepperAction:(id)sender {
	self.localPortTextField.intValue = self.localPortStepper.intValue;
    self.isDirty = self.userDefaultsController.hasUnappliedChanges;
}

- (IBAction)toggleAutoTurnOnProxy:(id)sender
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(IBAction)toggleLaunchAtLogin:(id)sender
{
    NSInteger state = self.startAtLoginButton.state;
    
    if (state == NSOnState) { // ON
        // Turn on launch at login
        if (!SMLoginItemSetEnabled ((__bridge CFStringRef)@"com.codinnstudio.sshproxyhelper", YES)) {
            NSAlert *alert = [NSAlert alertWithMessageText:@"An error ocurred"
                                             defaultButton:@"OK"
                                           alternateButton:nil
                                               otherButton:nil
                                 informativeTextWithFormat:@"Couldn't add SSH Proxy Helper App to launch at login item list."];
            [alert runModal];
        }
    }
    if (state == NSOffState) { // OFF
        // Turn off launch at login
        if (!SMLoginItemSetEnabled ((__bridge CFStringRef)@"com.codinnstudio.sshproxyhelper", NO)) {
            NSAlert *alert = [NSAlert alertWithMessageText:@"An error ocurred"
                                             defaultButton:@"OK"
                                           alternateButton:nil
                                               otherButton:nil
                                 informativeTextWithFormat:@"Couldn't remove SSH Proxy Helper App from launch at login item list."];
            [alert runModal];
        }
    }
}

- (IBAction)toggleShareSocks:(id)sender
{
    self.isDirty = self.userDefaultsController.hasUnappliedChanges;
}

- (void)dealloc
{
}

#pragma mark - BasePreferencesViewController

- (IBAction)applyChanges:(id)sender
{
    //    BOOL isProxyNeedReactive = [CSProxy getLocalPort]!=self.localPortTextField.integerValue;
    //    BOOL isSocksServerNeedRestart = [CSProxy isShareSOCKS]!=self.shareSocksButton.state;
    
    [self.userDefaultsController save:self];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.isDirty = NO;
    
    AppController *appController = (AppController *)([NSApplication sharedApplication].delegate);
    
    //    if (isSocksServerNeedRestart) {
    //        [appController performSelector: @selector(restartServer) withObject:nil afterDelay: 0.0];
    //    }
    
    // reactive proxy
    //    if (isProxyNeedReactive) {
    [appController performSelector: @selector(reactiveProxy:) withObject:self afterDelay: 0.0];
    //    }
}
- (IBAction)revertChanges:(id)sender
{
    [self.userDefaultsController revert:self];
    
    // save again to prevent dirty settings
    [self.userDefaultsController save:self];
    self.isDirty = NO;
}

@end
