//
//  ServersPreferencesViewController.m
//  sshproxy
//
//  Created by Brant Young on 14/5/13.
//  Copyright (c) 2013 Codinn Studio. All rights reserved.
//

#import "ServersPreferencesViewController.h"
#import "CharmNumberFormatter.h"
#import "SSHHelper.h"
#import "AuthTipViewController.h"
#import "AppController.h"
#import <pwd.h>

@implementation ServersPreferencesViewController

@synthesize authTipPopoverController;
@synthesize isDirty;

- (id)init
{
    return [super initWithNibName:@"ServersPreferencesView" bundle:nil];
}


#pragma mark - MASPreferencesViewController

- (NSString *)identifier
{
    return @"ServersPreferences";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNameNetwork];
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"sshproxy.pref.servers.title", nil);
}

#pragma mark -

-(void)loadView
{
    [super loadView];
    
    CharmNumberFormatter *formatter = [[CharmNumberFormatter alloc] init];
    [self.remotePortTextField setFormatter:formatter];
    
    if ([self.serversTableView numberOfRows]<=0) {
        [self performSelector: @selector(addServer:) withObject:self afterDelay: 0.0f];
    } else {
        NSInteger index = [SSHHelper getActivatedServerIndex];
        [self.serversTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
        
        // invoke tableViewSelectionDidChange
        [[NSNotificationCenter defaultCenter] postNotificationName:NSTableViewSelectionDidChangeNotification object:self.serversTableView];
    }
    
    self.remoteHostLabel.stringValue = NSLocalizedString(@"sshproxy.pref.servers.host", nil);
    self.remotePortLabel.stringValue = NSLocalizedString(@"sshproxy.pref.servers.port", nil);
    self.usernameLabel.stringValue = NSLocalizedString(@"sshproxy.pref.servers.username", nil);
    self.authenticationLabel.stringValue = NSLocalizedString(@"sshproxy.pref.servers.auth", nil);
    self.passwordRadioCell.title = NSLocalizedString(@"sshproxy.pref.servers.password", nil);
    self.pubkeyRadioCell.title = NSLocalizedString(@"sshproxy.pref.servers.pubkey", nil);
    self.advancedButton.title = NSLocalizedString(@"sshproxy.pref.servers.advanced", nil);
    self.duplicateMenuItem.title =NSLocalizedString(@"sshproxy.pref.servers.duplicate", nil);
    
    self.compressCheckbox.title = NSLocalizedString(@"sshproxy.pref.servers.compress", nil);
    self.throughProxyCheckbox.title = NSLocalizedString(@"sshproxy.pref.servers.through_proxy", nil);
    self.proxyTypeLabel.stringValue = NSLocalizedString(@"sshproxy.pref.servers.proxy_type", nil);
    self.proxyServerLabel.stringValue = NSLocalizedString(@"sshproxy.pref.servers.proxy_server", nil);
    self.authRequiredCheckbox.title = NSLocalizedString(@"sshproxy.pref.servers.proxy_auth", nil);
    self.proxyUsernameLabel.stringValue = NSLocalizedString(@"sshproxy.pref.servers.proxy_username", nil);
    self.proxyPasswordLabel.stringValue = NSLocalizedString(@"sshproxy.pref.servers.proxy_password", nil);
    self.okButton.title = NSLocalizedString(@"sshproxy.pref.servers.ok", nil);
}


#pragma mark - Actions

- (IBAction)remoteStepperAction:(id)sender
{
	self.remotePortTextField.intValue = self.remotePortStepper.intValue;
    self.isDirty = self.userDefaultsController.hasUnappliedChanges;
}

- (IBAction)showTheSheet:(id)sender
{
    [NSApp beginSheet:self.advancedPanel
       modalForWindow:self.view.window
        modalDelegate:self
       didEndSelector:nil
          contextInfo:nil];
}

- (IBAction)endTheSheet:(id)sender
{
    [NSApp endSheet:self.advancedPanel];
    [self.advancedPanel orderOut:sender];
    
    self.isDirty = self.userDefaultsController.hasUnappliedChanges;
}


- (IBAction)toggleAuthTipPopover:(id)sender
{
    if (self.authTipPopoverController.popoverIsVisible) {
        [self.authTipPopoverController closePopover:nil];
    } else {
        [self.authTipPopoverController presentPopoverFromRect:[sender bounds] inView:sender preferredArrowDirection:INPopoverArrowDirectionLeft anchorsToPositionView:YES];
    }
}


- (void)_addServer:(NSDictionary*)server
{
    [self.serverArrayController addObject:server];
    
    NSInteger index = [self.serversTableView numberOfRows]-1;
    [self.serversTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
    
    [self.remoteHostTextField becomeFirstResponder];
    [self.serversTableView scrollRowToVisible:index];
}

- (IBAction)removeServer:(id)sender
{
    NSInteger count = [self.serversTableView numberOfRows];
    
    NSUInteger index = [self.serverArrayController selectionIndex];
    [self.serverArrayController removeObjectAtArrangedObjectIndex:index];
    
    if (index==(count-1)) {
        index = index -1;
    }
    
    [self.serversTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
    [self.serversTableView scrollRowToVisible:index];
    [self.serversTableView.window makeFirstResponder:self.serversTableView];
    
    self.isDirty = self.userDefaultsController.hasUnappliedChanges;
}

- (IBAction)addServer:(id)sender
{
    NSMutableDictionary* defaultServer = [[NSMutableDictionary alloc] init];
    
    [defaultServer setObject:@"example.com" forKey:@"remote_host"];
    [defaultServer setObject:[NSNumber numberWithInt:22] forKey:@"remote_port"];
    [defaultServer setObject:@"user" forKey:@"login_name"];
    [defaultServer setObject:[NSNumber numberWithBool:NO] forKey:@"enable_compression"];
    [defaultServer setObject:[NSNumber numberWithBool:NO] forKey:@"share_socks"];
    
    [self _addServer:defaultServer];
    self.isDirty = self.userDefaultsController.hasUnappliedChanges;
}

- (IBAction)duplicateServer:(id)sender
{
    NSDictionary* server = (NSDictionary*)[self.serverArrayController.selectedObjects objectAtIndex:0];
    [self _addServer:[server mutableCopy]];
    self.isDirty = self.userDefaultsController.hasUnappliedChanges;
}

- (INPopoverController *)authTipPopoverController
{
    if (!authTipPopoverController) {
        AuthTipViewController *viewController = [[AuthTipViewController alloc] init];
        
        authTipPopoverController = [[INPopoverController alloc] initWithContentViewController:viewController];
    }
    
    return authTipPopoverController;
}


- (IBAction)authMethodChanged:(id)sender
{
    NSUInteger selectedTag = self.authMethodMatrix.selectedTag;
    
    if (OW_AUTH_METHOD_PUBLICKEY==selectedTag) {
        // http://stackoverflow.com/questions/10952225/is-there-any-way-to-give-my-sandboxed-mac-app-read-only-access-to-files-in-lib/10955994
        const char *home = getpwuid(getuid())->pw_dir;
        NSString *path = [[NSFileManager defaultManager]
                          stringWithFileSystemRepresentation:home
                          length:strlen(home)];
        NSURL *url = [NSURL fileURLWithPath:path isDirectory:YES];
        
        // Create the File Open Dialog class.
        NSOpenPanel* openDlg = [NSOpenPanel openPanel];
        
        // Enable the selection of files in the dialog.
        openDlg.canChooseFiles = YES;
        openDlg.title = @"Import Private Key";
        openDlg.prompt = @"Import Private Key";
        openDlg.message = @"Please choose a private key file:";
        
        openDlg.allowsMultipleSelection = NO;
        openDlg.directoryURL = [url URLByAppendingPathComponent:@".ssh" isDirectory:YES];
        
        [openDlg beginSheetModalForWindow:self.view.window
                        completionHandler:^(NSInteger returnCode) {
                            if (returnCode == NSOKButton) {
                                NSDictionary *server = [self.serverArrayController.selectedObjects objectAtIndex:0];
                                
                                if (server) {
                                    NSString *selectedKeyPath = openDlg.URL.path;
                                    
                                    [SSHHelper setPrivateKeyPath:selectedKeyPath forServer:server];
                                    
                                    NSString *importedKeyPath = [SSHHelper importedPrivateKeyPathFromServer:server];
                                    
                                    // copy key
                                    
                                    NSFileManager *defaultManager = [NSFileManager defaultManager];
                                    
                                    if ( [defaultManager fileExistsAtPath:importedKeyPath isDirectory:NO] )
                                    {
                                        [defaultManager removeItemAtPath:importedKeyPath error:nil];
                                    }
                                    
                                    [defaultManager copyItemAtPath:selectedKeyPath toPath:importedKeyPath error:nil];
                                    
                                    // set permission to 0600, or ssh will failed
                                    
                                    NSDictionary* attributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithShort:0600] forKey:NSFilePosixPermissions];
                                    [defaultManager setAttributes:attributes ofItemAtPath:importedKeyPath error:nil];
                                    
                                    // hack code to make sure user defaults controller is aware of server array controller is changed.
                                    NSUInteger selected = [self.serverArrayController selectionIndex];
                                    
                                    NSUInteger index = [self.serverArrayController.arrangedObjects count];
                                    [self.serverArrayController insertObject:server atArrangedObjectIndex:index];
                                    [self.serverArrayController removeObjectAtArrangedObjectIndex:index];
                                    
                                    // keep selection
                                    [self.serversTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:selected] byExtendingSelection:NO];
                                    [self.serversTableView scrollRowToVisible:selected];
                                    
                                    self.isDirty = self.userDefaultsController.hasUnappliedChanges;
                                }
                            }}];
    }
    self.isDirty = self.userDefaultsController.hasUnappliedChanges;
}

#pragma mark - BasePreferencesViewController

- (IBAction)applyChanges:(id)sender
{
    // rember index
    NSInteger index = [SSHHelper getActivatedServerIndex];
    NSUInteger selected = self.serverArrayController.selectionIndex;
    
    // apply changes
    [self.userDefaultsController save:self];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.isDirty = NO;
    
    if ( [self.serverArrayController.arrangedObjects count] <= 0) {
        return;
    }
    
    // recover selection
    NSDictionary* server = (NSDictionary*)[self.serverArrayController.arrangedObjects objectAtIndex:index];
    BOOL isProxyNeedReactive = ![server isEqualToDictionary:[SSHHelper getActivatedServer]];
    
    if (selected >= [self.serverArrayController.arrangedObjects count]) {
        selected = [self.serverArrayController.arrangedObjects count] -1;
    }
    
    self.serverArrayController.selectionIndex = selected;
    
    // reactive proxy
    if (isProxyNeedReactive) {
        AppController *appController = (AppController *)([NSApplication sharedApplication].delegate);
        
        // it seems must delay some microsenconds to wait user defaults synchronize
        [appController performSelector: @selector(reactiveProxy:) withObject:self afterDelay: 0.1];
    }
    
}

- (IBAction)revertChanges:(id)sender
{
    NSUInteger selected = self.serverArrayController.selectionIndex;
    
    [self.userDefaultsController revert:self];
    
    // save again to prevent dirty settings
    [self.userDefaultsController save:self];
    [self.userDefaultsController.defaults synchronize];
    
    self.isDirty = NO;
    
    if (selected >= [self.serverArrayController.arrangedObjects count]) {
        selected = [self.serverArrayController.arrangedObjects count] -1;
    }
    
    self.serverArrayController.selectionIndex = selected;
}
@end
