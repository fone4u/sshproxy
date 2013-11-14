//
//  ServersPreferencesViewController.h
//  sshproxy
//
//  Created by Brant Young on 14/5/13.
//  Copyright (c) 2013 Codinn Studio. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MASPreferencesViewController.h"
#import "INPopoverController.h"
#import "BasePreferencesViewController.h"

@interface ServersPreferencesViewController : BasePreferencesViewController <MASPreferencesViewController, NSTableViewDelegate>

- (IBAction)remoteStepperAction:(id)sender;

- (IBAction)duplicateServer:(id)sender;
- (IBAction)removeServer:(id)sender;
- (IBAction)addServer:(id)sender;

- (IBAction)showTheSheet:(id)sender;
- (IBAction)endTheSheet:(id)sender;

- (IBAction)toggleAuthTipPopover:(id)sender;

- (IBAction)authMethodChanged:(id)sender;

@property (strong) IBOutlet NSArrayController *serverArrayController;

@property (strong) IBOutlet NSTextField *remoteHostTextField;
@property (strong) IBOutlet NSTextField *remotePortTextField;
@property (strong) IBOutlet NSStepper *remotePortStepper;

@property (strong) IBOutlet NSTextField *loginNameTextField;
@property (strong) IBOutlet NSPanel *advancedPanel;
@property (strong) IBOutlet NSTableView *serversTableView;

@property (strong) IBOutlet NSMatrix *authMethodMatrix;
@property (strong) IBOutlet NSTextField *privatekeyLabel;


@property (strong) IBOutlet NSTextField *remoteHostLabel;
@property (strong) IBOutlet NSTextField *remotePortLabel;
@property (strong) IBOutlet NSTextField *usernameLabel;
@property (strong) IBOutlet NSTextField *authenticationLabel;
@property (strong) IBOutlet NSButtonCell *passwordRadioCell;
@property (strong) IBOutlet NSButtonCell *pubkeyRadioCell;
@property (strong) IBOutlet NSButton *advancedButton;
@property (strong) IBOutlet NSMenuItem *duplicateMenuItem;

@property (strong) IBOutlet NSButton *compressCheckbox;
@property (strong) IBOutlet NSButton *throughProxyCheckbox;
@property (strong) IBOutlet NSTextField *proxyTypeLabel;
@property (strong) IBOutlet NSTextField *proxyServerLabel;
@property (strong) IBOutlet NSButton *authRequiredCheckbox;
@property (strong) IBOutlet NSTextField *proxyUsernameLabel;
@property (strong) IBOutlet NSTextField *proxyPasswordLabel;
@property (strong) IBOutlet NSButton *okButton;

@property (nonatomic,readonly) INPopoverController *authTipPopoverController;

@end
