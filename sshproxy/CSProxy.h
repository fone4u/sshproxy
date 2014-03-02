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

@end
