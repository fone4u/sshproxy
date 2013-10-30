//
//  BasePreferencesViewController.h
//  sshproxy
//
//  Created by Brant Young on 10/30/13.
//  Copyright (c) 2013 Charm Studio. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BasePreferencesViewController : NSViewController

@property IBOutlet NSButton* revertButton;
@property IBOutlet NSButton* applyButton;
@property IBOutlet NSUserDefaultsController *userDefaultsController;

@property (nonatomic, readwrite) BOOL isDirty;

- (IBAction)applyChanges:(id)sender;
- (IBAction)revertChanges:(id)sender;
- (IBAction)closePreferencesWindow:(id)sender;

@end
