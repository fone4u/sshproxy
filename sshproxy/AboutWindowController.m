//
//  AboutWindowController.m
//  sshproxy
//
//  Created by Brant Young on 10/26/13.
//  Copyright (c) 2013 Charm Studio. All rights reserved.
//

#import "AboutWindowController.h"

@interface AboutWindowController ()

@end

@implementation AboutWindowController

- (id)init
{
    return [super initWithWindowNibName:@"AboutWindowController"];
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    NSString *title = NSLocalizedString(@"sshproxy.about.title", nil);
    self.window.title = title;
    
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    self.titleTextField.stringValue = appName;
    
    self.feedbackButton.title = NSLocalizedString(@"sshproxy.about.feedback", nil);
    self.rateUsButton.title = NSLocalizedString(@"sshproxy.about.rateus", nil);
    
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    self.versionTextField.stringValue = [NSString stringWithFormat: NSLocalizedString(@"sshproxy.about.version", nil), appVersion];
    
    self.releaseDateTextField.stringValue = NSLocalizedString(@"sshproxy.about.release", nil);
    self.copyrightTextField.stringValue = NSLocalizedString(@"sshproxy.about.copyright", nil);
    self.creditsTextField.stringValue = NSLocalizedString(@"sshproxy.about.credits", nil);
}


-(IBAction)openSendFeedback:(id)sender
{
    NSString *encodedSubject = @"subject=SSH Proxy Support";
    NSString *encodedBody = @"body=Hi Yang,";
    NSString *encodedTo = @"yang@codinnstudio.com";
    NSString *encodedURLString = [NSString stringWithFormat:@"mailto:%@?%@&%@",
                                  [encodedTo stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                  [encodedSubject stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                  [encodedBody stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    DDLogVerbose(@"%@", encodedURLString);
    NSURL *mailtoURL = [NSURL URLWithString:encodedURLString];
    [[NSWorkspace sharedWorkspace] openURL:mailtoURL];
}

-(IBAction)openMacAppStore:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:
     [NSURL URLWithString:@"macappstore://itunes.apple.com/app/ssh-proxy/id597790822?mt=12"]];
}

@end
