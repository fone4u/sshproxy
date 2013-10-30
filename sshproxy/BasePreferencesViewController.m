//
//  BasePreferencesViewController.m
//  sshproxy
//
//  Created by Brant Young on 10/30/13.
//  Copyright (c) 2013 Charm Studio. All rights reserved.
//

#import "BasePreferencesViewController.h"

@interface BasePreferencesViewController ()

@end

@implementation BasePreferencesViewController

@synthesize isDirty;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(void)loadView
{
    [super loadView];
    
    [self.userDefaultsController save:self];
    self.isDirty = NO;
    
    self.applyButton.title = NSLocalizedString(@"sshproxy.pref.apply", nil);
    self.revertButton.title = NSLocalizedString(@"sshproxy.pref.revert", nil);
}

- (IBAction)applyChanges:(id)sender
{
}


- (IBAction)revertChanges:(id)sender
{
}


- (IBAction)closePreferencesWindow:(id)sender {
    [self.view.window performClose:sender];
}

#pragma - NSViewController

- (BOOL)commitEditing
{
    BOOL shouldClose = YES;
    
    if (self.isDirty) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"The preference has changes that have not been applied. Would you like to apply them?" defaultButton:@"Apply" alternateButton:@"Don't Apply" otherButton:@"Cancel" informativeTextWithFormat:@""];
        
        alert.alertStyle = NSWarningAlertStyle;
        
        [alert beginSheetModalForWindow:self.view.window modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
        
        // a simple trick for waiting sheet modal return
        shouldClose = [NSApp runModalForWindow:alert.window];
    }
    
    return shouldClose;
}
- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    switch (returnCode) {
        case NSAlertDefaultReturn: // apply
            [self performSelector: @selector(applyChanges:) withObject:nil afterDelay: 0.0];
            [NSApp stopModalWithCode:YES];
            break;
            
        case NSAlertOtherReturn: // cancel
            [NSApp stopModalWithCode:NO];
            break;
            
        case NSAlertAlternateReturn: // don't apply
            [self performSelector: @selector(revertChanges:) withObject:nil afterDelay: 0.0];
            [NSApp stopModalWithCode:YES];
            break;
            
        default:
            [NSApp stopModalWithCode:YES];
            break;
    }
}

#pragma mark - NSControl

- (void)controlTextDidChange:(NSNotification *)aNotification
{
    self.isDirty = self.userDefaultsController.hasUnappliedChanges;
}

@end
