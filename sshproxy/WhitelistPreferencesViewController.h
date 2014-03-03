//
//  WhitelistPreferencesViewController.h
//  sshproxy
//
//  Created by Brant Young on 7/16/13.
//  Copyright (c) 2013 Codinn Studio. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MASPreferencesViewController.h"
#import "BasePreferencesViewController.h"

@interface WhitelistPreferencesViewController : BasePreferencesViewController <MASPreferencesViewController, NSTableViewDelegate>

@property (weak) IBOutlet NSArrayController *whitelistArrayController;
@property (weak) IBOutlet NSTableView *whitelistTableView;

- (IBAction)duplicateSite:(id)sender;
- (IBAction)removeSite:(id)sender;
- (IBAction)addSite:(id)sender;

- (IBAction)cellButtonClicked:(id)sender;
- (IBAction)importMenuClicked:(id)sender;
- (IBAction)emptyWhitelist:(id)sender;

@property (weak) IBOutlet NSTextField *tipsLabel;
@property (weak) IBOutlet NSTableColumn *enabledTableColumn;
@property (weak) IBOutlet NSTableColumn *addressTableColumn;
@property (weak) IBOutlet NSTableColumn *subdomainsTableColumn;

@property (weak) IBOutlet NSMenu *mainMenu;
@property (weak) IBOutlet NSMenuItem *duplicateMenuItem;
@property (weak) IBOutlet NSMenuItem *emptyMenuItem;
@property (weak) IBOutlet NSMenuItem *importAllMenuItem;
@property (weak) IBOutlet NSMenuItem *importDevMenuItem;
@end
