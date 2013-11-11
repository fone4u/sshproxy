//
//  WhitelistPreferencesViewController.m
//  sshproxy
//
//  Created by Brant Young on 7/16/13.
//  Copyright (c) 2013 Codinn Studio. All rights reserved.
//

#import "WhitelistPreferencesViewController.h"
#import "WhitelistHelper.h"

@interface WhitelistPreferencesViewController ()

@end

@implementation WhitelistPreferencesViewController

- (id)init
{
    return [super initWithNibName:@"WhitelistPreferencesView" bundle:nil];
}

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
    
    self.tipsLabel.stringValue = NSLocalizedString(@"sshproxy.pref.whitelist.tips", nil);
    
    [self.enabledTableColumn.headerCell setStringValue: NSLocalizedString(@"sshproxy.pref.whitelist.enabled", nil)];
    [self.addressTableColumn.headerCell setStringValue: NSLocalizedString(@"sshproxy.pref.whitelist.address", nil)];
    [self.subdomainsTableColumn.headerCell setStringValue: NSLocalizedString(@"sshproxy.pref.whitelist.subdomains", nil)];
    
    self.duplicateMenuItem.title = NSLocalizedString(@"sshproxy.pref.whitelist.duplicate", nil);
    self.emptyMenuItem.title = NSLocalizedString(@"sshproxy.pref.whitelist.empty", nil);
    self.importAllMenuItem.title = NSLocalizedString(@"sshproxy.pref.whitelist.import_all", nil);
    self.importDevMenu.title = NSLocalizedString(@"sshproxy.pref.whitelist.import_developer", nil);
    
    for (int i=0; i<self.mainMenu.numberOfItems; i++) {
        NSMenuItem *item = [self.mainMenu itemAtIndex:i];
        
        NSString *title = item.title;
        title = [title stringByReplacingOccurrencesOfString: @"Import" withString:NSLocalizedString(@"sshproxy.pref.whitelist.import", nil)];
        title = [title stringByReplacingOccurrencesOfString: @"sites" withString:NSLocalizedString(@"sshproxy.pref.whitelist.sites", nil)];
        
        item.title = title;
    }
}


#pragma mark - MASPreferencesViewController

- (NSString *)identifier
{
    return @"WhitelistPreferences";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNameAdvanced];
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"sshproxy.pref.whitelist.title", nil);
}

#pragma - Actions

- (IBAction)closePreferencesWindow:(id)sender {
    [self.view.window performClose:sender];
}

- (void)_addSite:(NSDictionary*)server
{
    [self.whitelistArrayController addObject:server];
    
    NSInteger index = [self.whitelistTableView numberOfRows]-1;
    [self.whitelistTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
    
    [self.whitelistTableView scrollRowToVisible:index];
    [self.whitelistTableView editColumn:1 row:index withEvent:nil select:YES];
}

- (IBAction)removeSite:(id)sender
{
    NSInteger count = [self.whitelistTableView numberOfRows];
    
    NSUInteger index = [self.whitelistArrayController selectionIndex];
    [self.whitelistArrayController removeObjectAtArrangedObjectIndex:index];
    
    if (index==(count-1)) {
        index = index -1;
    }
    
    [self.whitelistTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
    [self.whitelistTableView scrollRowToVisible:index];
    
    self.isDirty = self.userDefaultsController.hasUnappliedChanges;
}

- (IBAction)addSite:(id)sender
{
    NSDictionary* emptySite = [WhitelistHelper newSite:nil];
    
    [self _addSite:emptySite];
    self.isDirty = self.userDefaultsController.hasUnappliedChanges;
}

- (IBAction)duplicateSite:(id)sender
{
    NSDictionary* site = (NSDictionary*)[self.whitelistArrayController.selectedObjects objectAtIndex:0];
    [self _addSite:[site copy]];
    self.isDirty = self.userDefaultsController.hasUnappliedChanges;
}

- (IBAction)cellButtonClicked:(id)sender
{
    self.isDirty = self.userDefaultsController.hasUnappliedChanges;
}

- (IBAction)emptyWhitelist:(id)sender
{
    NSRange range = NSMakeRange(0, [[self.whitelistArrayController arrangedObjects] count]);
    [self.whitelistArrayController removeObjectsAtArrangedObjectIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
    
    self.isDirty = self.userDefaultsController.hasUnappliedChanges;
}

#pragma mark - Import sites

- (void)_importSites:(NSArray *)sites
{
    for ( NSString *address in sites ) {
        NSDictionary *site = [WhitelistHelper newSite:address];
        [self _addSite:site];
    }
}

- (IBAction)importMenuClicked:(id)sender
{
    NSMenuItem* menuItem = (NSMenuItem*)sender;
    
    NSArray *builtinSites = [WhitelistHelper builtinSites];
    
    if (menuItem.tag > builtinSites.count) {
        // import all sites
        for (NSArray *sites in builtinSites) {
            [self _importSites:sites];
        }
    } else {
        [self _importSites:builtinSites[menuItem.tag-1]];
    }
    
    self.isDirty = self.userDefaultsController.hasUnappliedChanges;
}

#pragma mark - BasePreferencesViewController

- (IBAction)applyChanges:(id)sender
{
    // rember index
    NSUInteger selected = self.whitelistArrayController.selectionIndex;
    
    // remove duplicates
    NSArray *sites = [NSArray arrayWithArray:[[NSSet setWithArray:self.whitelistArrayController.arrangedObjects] allObjects]];
    
    NSRange range = NSMakeRange(0, [[self.whitelistArrayController arrangedObjects] count]);
    [self.whitelistArrayController removeObjectsAtArrangedObjectIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
    
    [self.whitelistArrayController addObjects:sites];
    
    // apply changes
    [self.userDefaultsController save:self];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.isDirty = NO;
    
    if ( [self.whitelistArrayController.arrangedObjects count] <= 0) {
        return;
    }
    
    // recover selection
    if (selected >= [self.whitelistArrayController.arrangedObjects count]) {
        selected = [self.whitelistArrayController.arrangedObjects count] -1;
    }
    
    self.whitelistArrayController.selectionIndex = selected;
    [self.whitelistTableView scrollRowToVisible:selected];
}

- (IBAction)revertChanges:(id)sender
{
    NSUInteger selected = self.whitelistArrayController.selectionIndex;
    
    [self.userDefaultsController revert:self];
    
    // save again to prevent dirty settings
    [self.userDefaultsController save:self];
    [self.userDefaultsController.defaults synchronize];
    
    self.isDirty = NO;
    
    if (selected >= [self.whitelistArrayController.arrangedObjects count]) {
        selected = [self.whitelistArrayController.arrangedObjects count] -1;
    }
    
    self.whitelistArrayController.selectionIndex = selected;
    [self.whitelistTableView scrollRowToVisible:selected];
}
@end
