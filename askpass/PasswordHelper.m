//
//  PasswordHelper.m
//  sshproxy
//
//  Created by Brant Young on 21/6/13.
//  Copyright (c) 2013 Codinn Studio. All rights reserved.
//

#import "PasswordHelper.h"
#import "CSProxy.h"
#import "EMKeychain.h"

@implementation PasswordHelper


#pragma mark - Password Helper

//! Simply looks for the keychain entry corresponding to a username and hostname and returns it. Returns nil if the password is not found
+ (NSString *)passwordForHost:(NSString *)hostName port:(int) hostPort user:(NSString *) userName
{
	if ( hostName == nil || userName == nil ){
		return nil;
	}
	
	EMInternetKeychainItem *keychainItem = [EMInternetKeychainItem internetKeychainItemForServer:hostName withUsername:userName path:nil port:hostPort protocol:kSecProtocolTypeSSH];
    
    return keychainItem ? keychainItem.password : @"";
}

+ (NSString *)passwordForServer:(CSProxy *)server
{
    NSString* remoteHost = server.ssh_host;
    NSString* loginName = server.ssh_user;
    int remotePort = server.ssh_port.intValue;
    
    return [self passwordForHost:remoteHost port:remotePort user:loginName];
}


/*! Set the password into the keychain for a specific user and host. If the username/hostname combo already has an entry in the keychain then change it. If not then add a new entry */
+ (BOOL)setPassword:(NSString*)newPassword forHost:(NSString*)hostName port:(int) hostPort user:(NSString*) userName
{
	if ( hostName == nil || userName == nil ) {
		return NO;
	}
	
	// Look for a password in the keychain
    EMInternetKeychainItem *keychainItem = [EMInternetKeychainItem internetKeychainItemForServer:hostName withUsername:userName path:nil port:hostPort protocol:kSecProtocolTypeSSH];
    
    if (!keychainItem) {
        keychainItem = [EMInternetKeychainItem addInternetKeychainItemForServer:hostName withUsername:userName password:newPassword path:nil port:hostPort protocol:kSecProtocolTypeSSH];
        return NO;
    }
    
    keychainItem.password = newPassword;
    return YES;
}
+ (BOOL)setPassword:(NSString *)newPassword forServer:(CSProxy *)server
{
    NSString* remoteHost = server.ssh_host;
    NSString* loginName = server.ssh_user;
    int remotePort = server.ssh_port.intValue;
    
    return [self setPassword:newPassword forHost:remoteHost port:remotePort user:loginName];
}

+ (BOOL)deletePasswordForHost:(NSString*)hostName port:(int) hostPort user:(NSString*) userName
{
	if ( hostName == nil || userName == nil ) {
		return NO;
	}
    
	// Look for a password in the keychain
    EMInternetKeychainItem *keychainItem = [EMInternetKeychainItem internetKeychainItemForServer:hostName withUsername:userName path:nil port:hostPort protocol:kSecProtocolTypeSSH];
    
    if (!keychainItem) {
        return NO;
    }
    
    [EMInternetKeychainItem removeKeychainItem:keychainItem];
    return YES;
}

#pragma mark - Passphrase Helper

//! Simply looks for the keychain entry corresponding to a username and hostname and returns it. Returns nil if the password is not found
+ (NSString *)passphraseForServer:(CSProxy *)server
{
	if ( !server ){
		return nil;
	}
	
	EMGenericKeychainItem *keychainItem = [EMGenericKeychainItem genericKeychainItemForService:@"com.codinnstudio.sshproxy.privatekey" withUsername:[server importedPrivateKeyName]];
    
    return keychainItem ? keychainItem.password : @"";
}


/*! Set the password into the keychain for a specific user and host. If the username/hostname combo already has an entry in the keychain then change it. If not then add a new entry */
+ (BOOL)setPassphrase:(NSString *)newPassphrase forServer:(CSProxy *)server
{
	if ( !server ) {
		return NO;
	}
	
	// Look for a password in the keychain
    EMGenericKeychainItem *keychainItem = [EMGenericKeychainItem genericKeychainItemForService:@"com.codinnstudio.sshproxy.privatekey" withUsername:[server importedPrivateKeyName]];
    
    if (!keychainItem) {
        keychainItem = [EMGenericKeychainItem addGenericKeychainItemForService:@"com.codinnstudio.sshproxy.privatekey" withUsername:[server importedPrivateKeyName] password:newPassphrase];
        return NO;
    }
    
    keychainItem.password = newPassphrase;
    return YES;
}

+ (BOOL)deletePassphraseForServer:(CSProxy *)server
{
	if ( !server ) {
		return NO;
	}
    
	// Look for a password in the keychain
    EMGenericKeychainItem *keychainItem = [EMGenericKeychainItem genericKeychainItemForService:@"com.codinnstudio.sshproxy.privatekey" withUsername:[server importedPrivateKeyName]];
    
    if (!keychainItem) {
        return NO;
    }
    
    [EMGenericKeychainItem removeKeychainItem:keychainItem];
    return YES;
}

#pragma mark Prompt Password

+ (NSArray *)promptPasswordForServer:(CSProxy *)server
{
    NSString* remoteHost = server.ssh_host;
    NSString* loginUser = server.ssh_user;
    int remotePort = server.ssh_port.intValue;
    
    BOOL isPublicKeyMode = server.auth_method.integerValue == CSSSHAuthMethodPassword;
    
	CFUserNotificationRef passwordDialog;
	SInt32 error;
	CFOptionFlags responseFlags;
	int button;
	CFStringRef passwordRef;
    
	NSMutableArray *returnArray = [NSMutableArray arrayWithObjects:@"PasswordString",@0,@1,nil];
    
    NSString* hostString = [NSString stringWithFormat:@"%@:%d", remoteHost, remotePort];
    
    NSString *passwordMessageString = nil;
    NSString *remeberCheckBoxTitle = nil;
    if (isPublicKeyMode) {
        passwordMessageString = [NSString stringWithFormat:@"Enter the passphrase for private key imported from “%@”.", server.privatekey_path];
        remeberCheckBoxTitle = @"Remember this passphrase in my keychain";
    } else {
        passwordMessageString = [NSString stringWithFormat:@"Enter the password for user “%@”.", loginUser];
        remeberCheckBoxTitle = @"Remember this password in my keychain";
    }
    
    NSString* headerString = [NSString stringWithFormat:@"SSH Proxy connecting to the SSH server “%@”.", hostString];
    
    NSURL *iconURL = [[NSBundle mainBundle] URLForResource:@"AppIcon" withExtension:@"icns" subdirectory:@""];
    
	NSDictionary *panelDict = @{(id)kCFUserNotificationIconURLKey: iconURL,
                               (id)kCFUserNotificationAlertHeaderKey: headerString,
                               (id)kCFUserNotificationAlertMessageKey: passwordMessageString,
							   (id)kCFUserNotificationTextFieldTitlesKey: @"",
							   (id)kCFUserNotificationAlternateButtonTitleKey: @"Cancel",
                               (id)kCFUserNotificationCheckBoxTitlesKey: remeberCheckBoxTitle};
    
	passwordDialog = CFUserNotificationCreate(kCFAllocatorDefault,
											  0,
											  kCFUserNotificationPlainAlertLevel
											  | CFUserNotificationSecureTextField(0)
                                              | CFUserNotificationCheckBoxChecked(0),
											  &error,
											  (__bridge CFDictionaryRef)panelDict);
    
    
	if (error){
		// There was an error creating the password dialog
		CFRelease(passwordDialog);
        returnArray[1] = @(error);
		return returnArray;
	}
    
	error = CFUserNotificationReceiveResponse(passwordDialog,
											  0,
											  &responseFlags);
    
	if (error){
		CFRelease(passwordDialog);
        returnArray[1] = @(error);
		return returnArray;
	}
    
    
	button = responseFlags & 0x3;
	if (button == kCFUserNotificationAlternateResponse) {
		CFRelease(passwordDialog);
        returnArray[1] = @1;
		return returnArray;
	}
    
	if ( responseFlags & CFUserNotificationCheckBoxChecked(0) ) {
        returnArray[2] = @0;
	}
	passwordRef = CFUserNotificationGetResponseValue(passwordDialog,
													 kCFUserNotificationTextFieldValuesKey,
													 0);
    
    
    returnArray[0] = (__bridge NSString*)passwordRef;
	CFRelease(passwordDialog); // Note that this will release the passwordRef as well
	return returnArray;
}


@end
