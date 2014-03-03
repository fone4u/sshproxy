//
//  ServersPreferencesViewController.h
//  sshproxy
//
//  Created by Brant Young on 14/5/13.
//  Copyright (c) 2013 Codinn Studio. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MASPreferencesViewController.h"
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

@property (weak) IBOutlet NSArrayController *serverArrayController;

@property (weak) IBOutlet NSTextField *remoteHostTextField;
@property (weak) IBOutlet NSTextField *remotePortTextField;
@property (weak) IBOutlet NSStepper *remotePortStepper;

@property (weak) IBOutlet NSTextField *loginNameTextField;
@property (weak) IBOutlet NSPanel *advancedPanel;
@property (weak) IBOutlet NSTableView *serversTableView;

@property (weak) IBOutlet NSMatrix *authMethodMatrix;
@property (weak) IBOutlet NSTextField *privatekeyLabel;


@property (weak) IBOutlet NSTextField *remoteHostLabel;
@property (weak) IBOutlet NSTextField *remotePortLabel;
@property (weak) IBOutlet NSTextField *usernameLabel;
@property (weak) IBOutlet NSTextField *authenticationLabel;
@property (weak) IBOutlet NSButtonCell *passwordRadioCell;
@property (weak) IBOutlet NSButtonCell *pubkeyRadioCell;
@property (weak) IBOutlet NSButton *advancedButton;
@property (weak) IBOutlet NSMenuItem *duplicateMenuItem;

@property (weak) IBOutlet NSButton *compressCheckbox;
@property (weak) IBOutlet NSButton *throughProxyCheckbox;
@property (weak) IBOutlet NSTextField *proxyTypeLabel;
@property (weak) IBOutlet NSTextField *proxyServerLabel;
@property (weak) IBOutlet NSButton *authRequiredCheckbox;
@property (weak) IBOutlet NSTextField *proxyUsernameLabel;
@property (weak) IBOutlet NSTextField *proxyPasswordLabel;
@property (weak) IBOutlet NSButton *okButton;
@property (weak) IBOutlet NSPopover *helpPopover;

@end
