//
//  CSProxy.h
//  sshproxy
//
//  Created by Brant Young on 3/2/14.
//  Copyright (c) 2014 Charm Studio. All rights reserved.
//

#import "CSSSHBaseInfo.h"

#define OW_SSHPROXY_ASKPASS_LOCK @".sshproxy_askpass_lock"
#define OW_SSHPROXY_DECRYPT_LOCK @".sshproxy_decrypt_lock"

@interface CSProxy : CSSSHBaseInfo

#pragma mark - Included in Persistent
@property (nonatomic) NSString              *proxy_id;
@property (nonatomic) NSNumber              *lan_share;
@property (nonatomic) NSNumber              *forward_port;
@property (nonatomic) NSNumber              *proxy_command;
@property (nonatomic) NSNumber              *proxy_command_type;
@property (nonatomic) NSString              *proxy_command_host;
@property (nonatomic) NSNumber              *proxy_command_port;
@property (nonatomic) NSNumber              *proxy_command_auth;
@property (nonatomic) NSString              *proxy_command_username;
@property (nonatomic) NSString              *proxy_command_password;
@property (nonatomic) NSString              *privatekey_path;

// Private Key
- (NSString *)importedPrivateKeyName;
- (NSString *)importedPrivateKeyPath;

- (NSMutableArray*)getPasswordMethodConnectArgs;
- (NSMutableArray*)getPublicKeyMethodConnectArgs;


// for ProxyCommand
-(NSDictionary *) getProxyCommandEnv;
-(NSString *)getProxyCommandStr;

+ (NSArray *)getProxyServers;
+ (NSInteger)getActivatedServerIndex;
+ (CSProxy*)getActivatedServer;
+ (void)setActivatedServer:(int)index;

// for local settings
+ (NSInteger)getLocalPort;
+ (NSInteger)getSSHLocalPort;
+ (BOOL)isShareSOCKS;


+ (NSString *)encryptServerInfo:(NSDictionary *)server;
+ (NSDictionary *)decryptServerInfo:(NSString *)encryptedServerInfo forDir:(NSString *)dir;

// code that upgrade user preferences from 13.04 to 14.03
+ (void)upgrade1:(NSArrayController *)proxyArrayController;

// code that upgrade user preferences to 14.03
+ (void)upgrade2:(NSArrayController*)proxyArrayController;

@end
