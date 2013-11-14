//
//  AboutWindowController.h
//  sshproxy
//
//  Created by Brant Young on 10/26/13.
//  Copyright (c) 2013 Charm Studio. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AboutWindowController : NSWindowController

@property IBOutlet NSTextField* titleTextField;

@property IBOutlet NSButton* feedbackButton;
@property IBOutlet NSButton* rateUsButton;
@property IBOutlet NSTextField* versionTextField;
@property IBOutlet NSTextField* releaseDateTextField;
@property IBOutlet NSTextField* copyrightTextField;
@property IBOutlet NSTextField* creditsTextField;

- (IBAction)openSendFeedback:(id)sender;
- (IBAction)openMacAppStore:(id)sender;

@end
