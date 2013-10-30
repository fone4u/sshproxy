//
//  PreferencesWindow.h
//  sshproxy
//
//  Created by Brant Young on 16/1/13.
//  Copyright (c) 2013 Codinn Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MASPreferencesViewController.h"
#import "BasePreferencesViewController.h"

@interface GeneralPreferencesViewController : BasePreferencesViewController <MASPreferencesViewController>

- (IBAction)localStepperAction:(id)sender;
- (IBAction)toggleAutoTurnOnProxy:(id)sender;
- (IBAction)toggleLaunchAtLogin:(id)sender;
- (IBAction)toggleShareSocks:(id)sender;

@property IBOutlet NSTextField* localPortTextField;
@property IBOutlet NSStepper* localPortStepper;
@property IBOutlet NSButton* autoConnectButton;
@property IBOutlet NSButton* startAtLoginButton;

@property IBOutlet NSBox* socksBox;
@property IBOutlet NSTextField* listeningTextField;
@property IBOutlet NSTextField* listeningRangeTextField;
@property IBOutlet NSButton* shareButton;

@end