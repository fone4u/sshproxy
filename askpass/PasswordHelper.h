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

// passphrase helper
+ (BOOL)setPassphrase:(NSString *)newPassphrased forServer:(CSProxy *)server;
+ (BOOL)deletePassphraseForServer:(CSProxy *)server;
+ (NSString *)passphraseForServer:(CSProxy *)server;

+ (NSArray *)promptPasswordForServer:(CSProxy *)server;

@end
