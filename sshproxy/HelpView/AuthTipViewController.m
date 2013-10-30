//
//  PasswordHelpViewController.m
//  sshproxy
//
//  Created by Brant Young on 19/6/13.
//  Copyright (c) 2013 Codinn Studio. All rights reserved.
//

#import "AuthTipViewController.h"

@interface AuthTipViewController ()

@end

@implementation AuthTipViewController

@synthesize tipTextField;

- (id)init
{
    return [super initWithNibName:@"AuthTipView" bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    
    return self;
}

- (void) awakeFromNib
{
//    NSData *htmlData = [NSLocalizedString(@"sshproxy.pref.servers.auth_tip", nil) dataUsingEncoding:NSUTF8StringEncoding];
//    NSAttributedString *html = [[NSAttributedString alloc] initWithHTML:htmlData baseURL: NULL documentAttributes: NULL];
    
    tipTextField.stringValue = NSLocalizedString(@"sshproxy.pref.servers.auth_tip", nil);
}

@end
