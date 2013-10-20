#import <Foundation/Foundation.h>
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "DDFileLogger.h"
#import "WhitelistHelper.h"
@interface OWProxyModeAllSitesTransformer : NSValueTransformer

@end

@implementation OWProxyModeAllSitesTransformer

+ (Class)transformedValueClass
{
    return [NSData class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    return [NSNumber numberWithBool:[value integerValue]==OW_PROXY_MODE_ALLSITES];
}
@end

@interface OWProxyModeWhitelistTransformer : NSValueTransformer

@end

@implementation OWProxyModeWhitelistTransformer

+ (Class)transformedValueClass
{
    return [NSData class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    return [NSNumber numberWithBool:[value integerValue]==OW_PROXY_MODE_WHITELIST];
}
@end

@interface OWProxyModeDirectTransformer : NSValueTransformer

@end

@implementation OWProxyModeDirectTransformer

+ (Class)transformedValueClass
{
    return [NSData class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    return [NSNumber numberWithBool:[value integerValue]==OW_PROXY_MODE_DIRECT];
}
@end

int main(int argc, char *argv[]) {
    @autoreleasepool
    {
    #ifdef DEBUG
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
    #endif
        DDFileLogger* fileLogger = [[DDFileLogger alloc] init];
        fileLogger.maximumFileSize = 1024*1024; // 1MB
        fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
        
        [DDLog addLogger:fileLogger];
        
        NSString * const OWProxyModeAllSitesTransformerName = @"OWProxyModeAllSites";
        NSString * const OWProxyModeWhitelistTransformerName = @"OWProxyModeWhitelist";
        NSString * const OWProxyModeDirectTransformerName = @"OWProxyModeDirect";
        
        OWProxyModeAllSitesTransformer *transformer = [[OWProxyModeAllSitesTransformer alloc] init];
        [NSValueTransformer setValueTransformer:transformer forName:OWProxyModeAllSitesTransformerName];
        
        OWProxyModeWhitelistTransformer *transformer2 = [[OWProxyModeWhitelistTransformer alloc] init];
        [NSValueTransformer setValueTransformer:transformer2 forName:OWProxyModeWhitelistTransformerName];
        
        OWProxyModeDirectTransformer *transformer3 = [[OWProxyModeDirectTransformer alloc] init];
        [NSValueTransformer setValueTransformer:transformer3 forName:OWProxyModeDirectTransformerName];
        
        return NSApplicationMain(argc, (const char **)argv);
    }
}
