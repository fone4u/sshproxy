//
//  PasswordHelper.h
//  sshproxy
//
//  Created by Brant Young on 21/6/13.
//  Copyright (c) 2013 Codinn Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CSProxy;

@interface PasswordHelper : NSObject

// password helper
+ (BOOL)setPassword:(NSString *)newPassword forHost:(NSString*)hostname port:(int) hostport user:(NSString *) username;
+ (BOOL)setPassword:(NSString *)newPassword forServer:(CSProxy *)server;

+ (BOOL)deletePasswordForHost:(NSString *)hostname port:(int) hostport user:(NSString *) username;
+ (NSString *)passwordForHost:(NSString *)hostname port:(int) hostport user:(NSString *) username;
+ (NSString *)passwordForServer:(CSProxy *)server;

// passphrase helper
+ (BOOL)setPassphrase:(NSString *)newPassphrased forServer:(CSProxy *)server;
+ (BOOL)deletePassphraseForServer:(CSProxy *)server;
+ (NSString *)passphraseForServer:(CSProxy *)server;

+ (NSArray *)promptPasswordForServer:(CSProxy *)server;

@end
