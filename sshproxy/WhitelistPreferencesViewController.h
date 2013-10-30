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

@property (strong) IBOutlet NSArrayController *whitelistArrayController;
@property (strong) IBOutlet NSTableView *whitelistTableView;

- (IBAction)duplicateSite:(id)sender;
- (IBAction)removeSite:(id)sender;
- (IBAction)addSite:(id)sender;

- (IBAction)cellButtonClicked:(id)sender;
- (IBAction)importMenuClicked:(id)sender;
- (IBAction)emptyWhitelist:(id)sender;

@end
