//
//  CSProxy.h
//  sshproxy
//
//  Created by Brant Young on 3/2/14.
//  Copyright (c) 2014 Charm Studio. All rights reserved.
//

#import "CSSSHBaseInfo.h"

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

@end
