//
//  CSProxy.m
//  sshproxy
//
//  Created by Brant Young on 3/2/14.
//  Copyright (c) 2014 Charm Studio. All rights reserved.
//
#import "RNEncryptor.h"
#import "RNDecryptor.h"
#import "NSString+SSToolkitAdditions.h"
#import "NSData+SSToolkitAdditions.h"
#import "NSDictionary+SSToolkitAdditions.h"
#import "CSProxy.h"
#import "CSProxy.h"

@implementation CSProxy

- (instancetype)init
{
    self = [super init];
    if (self) {
        // default values
        self.proxy_id    = CSGenerateUniqueId();
    }
    return self;
}

#pragma mark NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
	CSProxy *copied = [[self.class allocWithZone:zone] initWithDictionary:self.dictionaryValue error:NULL];
    // assign a different
    copied.proxy_id = CSGenerateUniqueId();
    return copied;
}

// for ProxyCommand
- (NSString*)getProxyCommandStr
{
    NSString *connectPath = [NSBundle pathForResource:@"connect" ofType:@""
                                          inDirectory:[[NSBundle mainBundle] bundlePath]];
    
    BOOL proxyCommand = self.proxy_command.boolValue;
    int proxyCommandType = self.proxy_command_type.intValue;
    NSString* proxyCommandHost = self.proxy_command_host;
    int proxyCommandPort = self.proxy_command_port.intValue;
    
    NSString* proxyCommandStr = nil;
    if (proxyCommand){
        if (proxyCommandHost) {
            NSString* proxyType = @"-S";
            
            switch (proxyCommandType) {
                case 0:
                    proxyType = @"-5 -S";
                    break;
                case 1:
                    proxyType = @"-4 -S";
                    break;
                case 2:
                    proxyType = @"-H";
                    break;
            }
            
            if (proxyCommandPort<=0 || proxyCommandPort>65535) {
                proxyCommandPort = 1080;
            }
            
            proxyCommandStr = [NSString stringWithFormat:@"-oProxyCommand=\"%@\" -d -w 8 %@ %@:%d %@", connectPath, proxyType, proxyCommandHost, proxyCommandPort, @"%h %p"];
        }
    }
    
    return proxyCommandStr;
}

// for ProxyCommand Env
- (NSDictionary*)getProxyCommandEnv
{
    NSMutableDictionary* env = [NSMutableDictionary dictionary];
    
    BOOL proxyCommand = self.proxy_command.boolValue;
    BOOL proxyCommandAuth = self.proxy_command_auth.boolValue;
    
    NSString* proxyCommandUsername = self.proxy_command_username;
    NSString* proxyCommandPassword = self.proxy_command_password;
    
    if (proxyCommand && proxyCommandAuth) {
        if (proxyCommandUsername) {
            [env setValue:@"YES" forKey:@"HTTP_PROXY_FORCE_AUTH"];
            [env setValue:proxyCommandUsername forKey:@"CONNECT_USER"];
            if (proxyCommandPassword) {
                [env setValue:proxyCommandPassword forKey:@"CONNECT_PASSWORD"];
            }
        }
    }
    
    return env;
}

#pragma mark Others

+ (NSArray *)getProxyServers
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] valueForKey:@"proxies"]];
}

+ (NSInteger)getActivatedServerIndex
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSArray* servers = [self getProxyServers];
    NSInteger index = [prefs integerForKey:@"activated_server"];
    
    if (index<0 || index>=servers.count) {
        index = 0;
    }
    
    return index;
}


+ (CSProxy *)getActivatedServer
{
    NSArray* servers = [self getProxyServers];
    
    if ( [servers count]<=0 ){
        return nil;
    }
    
    NSInteger index = [self getActivatedServerIndex];
    return servers[index];
}

#pragma mark - Local Settings

+ (NSInteger)getLocalPort
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSInteger localPort = [prefs integerForKey:@"local_port"];
    
    if (localPort<1024 || localPort>65535) {
        localPort = 7070;
    }
    
    return localPort;
}
+ (NSInteger)getSSHLocalPort
{
    return [self getLocalPort]+1;
}
+ (BOOL)isShareSOCKS
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    return [prefs boolForKey:@"share_socks"];
}


#pragma mark - Server info encrypt / decrypt

+ (NSString *)encryptServerInfo:(CSProxy *)server
{
    NSString* userHome = NSHomeDirectory();
    NSString* lockFile= [userHome stringByAppendingPathComponent:OW_SSHPROXY_DECRYPT_LOCK];
    NSString* serverInfo = [server.dictionaryValue stringWithFormEncodedComponents];
    
    // touch lock file
    {
        // [[NSFileManager defaultManager] createFileAtPath:lockFile contents:nil attributes: nil];
        // use plain c to avoid create unprivileged cache file
        FILE *fh = fopen([lockFile UTF8String], "w");
        fclose(fh);
    }
    
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:lockFile error:nil];
    NSString *digest = attributes ? [attributes.description MD5Sum] : [lockFile MD5Sum];
    
    NSData *data = [serverInfo dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    
    NSData *encryptedData = [RNEncryptor encryptData: data
                                        withSettings: kRNCryptorAES256Settings
                                            password: digest
                                               error: &error];
    
    return [encryptedData base64EncodedString];
}
+ (CSProxy *)decryptServerInfo:(NSString *)encryptedServerInfo forDir:(NSString *)dir
{
    NSString* lockFile= [dir stringByAppendingPathComponent:OW_SSHPROXY_DECRYPT_LOCK];
    
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:lockFile error:nil];
    NSString *digest = attributes ? [attributes.description MD5Sum] : [lockFile MD5Sum];
    
    NSData *encryptedData = [NSData dataWithBase64String:encryptedServerInfo ];
    NSError *error;
    NSData *decryptedData = [RNDecryptor decryptData:encryptedData
                                        withPassword:digest
                                               error:&error];
    
    NSString *serverInfo = [[NSString alloc] initWithData:decryptedData
                                                 encoding:NSUTF8StringEncoding];
    return [[CSProxy alloc] initWithDictionary:[NSDictionary dictionaryWithFormEncodedString:serverInfo] error:nil];
}

// code that upgrade user preferences from 13.04 to 14.03
+ (void)upgrade1:(NSArrayController*)proxyArrayController
{
    // fetch preferences that need upgrade
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSString* remoteHost = [prefs stringForKey:@"remote_host"];
    if (!remoteHost) {
        // do not need upgrade
        return;
    }
    
    // upgrade
    
    CSProxy *proxy = [[CSProxy alloc] init];
    
    proxy.ssh_host = [prefs objectForKey:@"remote_host"];
    proxy.ssh_port = [prefs objectForKey:@"remote_port"];
    proxy.ssh_user = [prefs stringForKey:@"login_name"];
    proxy.enable_compression = [prefs objectForKey:@"enable_compression"];
    proxy.proxy_command = [prefs objectForKey:@"proxy_command"];
    proxy.proxy_command_type = [prefs objectForKey:@"proxy_command_type"];
    proxy.proxy_command_host = [prefs stringForKey:@"proxy_command_host"];
    proxy.proxy_command_port = [prefs objectForKey:@"proxy_command_port"];
    proxy.proxy_command_auth = [prefs objectForKey:@"proxy_command_auth"];
    proxy.proxy_command_username = [prefs stringForKey:@"proxy_command_username"];
    proxy.proxy_command_password = [prefs stringForKey:@"proxy_command_password"];
    [proxyArrayController addObject:proxy];
    
    // remove old preferences
    
    [prefs removeObjectForKey:@"remote_host"];
    [prefs removeObjectForKey:@"remote_port"];
    [prefs removeObjectForKey:@"login_name"];
    
    [prefs removeObjectForKey:@"enable_compression"];
    
    [prefs removeObjectForKey:@"proxy_command"];
    [prefs removeObjectForKey:@"proxy_command_type"];
    [prefs removeObjectForKey:@"proxy_command_host"];
    [prefs removeObjectForKey:@"proxy_command_port"];
    
    [prefs removeObjectForKey:@"proxy_command_auth"];
    [prefs removeObjectForKey:@"proxy_command_username"];
    [prefs removeObjectForKey:@"proxy_command_password"];
    
    [prefs synchronize];
}

// code that upgrade user preferences to 14.03
+ (void)upgrade2:(NSArrayController*)proxyArrayController
{
    // fetch preferences that need upgrade
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSArray *servers = [[NSUserDefaults standardUserDefaults] arrayForKey:@"servers"];
    
    if (!servers) {
        // do not need upgrade
        return;
    }
    
    // upgrade
    for (NSDictionary* server in servers) {
        CSProxy *proxy = [[CSProxy alloc] init];
        
        proxy.ssh_host = server[@"remote_host"];
        proxy.ssh_port = server[@"remote_port"];
        proxy.ssh_user = server[@"login_name"];
        proxy.auth_method = server[@"auth_method"];
        proxy.enable_compression = server[@"enable_compression"];
        proxy.proxy_command = server[@"proxy_command"];
        proxy.proxy_command_type = server[@"proxy_command_type"];
        proxy.proxy_command_host = server[@"proxy_command_host"];
        proxy.proxy_command_port = server[@"proxy_command_port"];
        proxy.proxy_command_auth = server[@"proxy_command_auth"];
        proxy.proxy_command_username = server[@"proxy_command_username"];
        proxy.proxy_command_password = server[@"proxy_command_password"];
        
        // private key
        proxy.privatekey_path = server[@"privatekey_path"];
        
        [proxyArrayController addObject:proxy];
    }
    
    // remove old preferences
    [prefs removeObjectForKey:@"servers"];
    [prefs synchronize];
}

#pragma mark Private key

- (NSString *)importedPrivateKeyName
{
    return [self.privatekey_path MD5Sum];
}

- (NSString *)importedPrivateKeyPath
{
    // create ".ssh" dir at sandbox container
    NSString *importedKeyDir = [NSHomeDirectory() stringByAppendingPathComponent:@".ssh"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:importedKeyDir])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:importedKeyDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *importedKeyName = [self importedPrivateKeyName];
    NSString *importedKeyPath = [importedKeyDir stringByAppendingPathComponent:importedKeyName];
    
    return importedKeyPath;
}

+ (void)setActivatedServer:(int) index
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs setInteger:index forKey:@"activated_server"];
    [prefs synchronize];
}

- (NSMutableArray*)_getCommonConnectArgs
{
    NSString* knownHostFile = @"/dev/null";
    //    NSString* knownHostFile= [userHome stringByAppendingPathComponent:@".sshproxy_known_hosts"];
    //    NSString* configFile= [NSHomeDirectory() stringByAppendingPathComponent:@".sshproxy_config"];
    
    NSMutableArray *arguments = [NSMutableArray arrayWithObjects:
                                 [NSString stringWithFormat:@"-oUserKnownHostsFile=\"%@\"", knownHostFile],
                                 [NSString stringWithFormat:@"-oGlobalKnownHostsFile=\"%@\"", knownHostFile],
                                 // TODO:
                                 //                                 [NSString stringWithFormat:@"-F \"%@\"", configFile],
                                 @"-oIdentitiesOnly=yes",
                                 @"-oPubkeyAuthentication=yes",
                                 @"-oAskPassGUI=no", // TODO: OS X 10.6 may fail
                                 @"-T", @"-a",
                                 @"-oConnectTimeout=8", @"-oConnectionAttempts=1",
                                 @"-oServerAliveInterval=8", @"-oServerAliveCountMax=1",
                                 @"-oStrictHostKeyChecking=no", @"-oExitOnForwardFailure=yes",
                                 @"-oNumberOfPasswordPrompts=3", @"-oLogLevel=DEBUG",
                                 nil];
    
    return arguments;
}

- (NSMutableArray*)getPasswordMethodConnectArgs
{
    NSMutableArray *arguments = [self _getCommonConnectArgs];
    
    [arguments addObjectsFromArray:@[
                                     [NSString stringWithFormat:@"-oIdentityFile=\"%@\"", [NSHomeDirectory() stringByAppendingPathComponent:@".sshproxy_identity"]],
                                     @"-oPreferredAuthentications=keyboard-interactive,password",
                                     @"-oPubkeyAuthentication=no"]
     ];
    
    return arguments;
}

- (NSMutableArray*)getPublicKeyMethodConnectArgs
{
    NSString* privateKeyPath= [self importedPrivateKeyPath];
    
    if ( ![[NSFileManager defaultManager] fileExistsAtPath:privateKeyPath isDirectory:NO] ) {
        // return nil if imported private key miss
        return nil;
    }
    
    NSMutableArray *arguments = [self _getCommonConnectArgs];
    
    [arguments addObjectsFromArray:@[
                                     [NSString stringWithFormat:@"-oIdentityFile=\"%@\"", privateKeyPath],
                                     @"-oPreferredAuthentications=publickey",
                                     @"-oPubkeyAuthentication=yes"]
     ];
    
    return arguments;
}

@end
