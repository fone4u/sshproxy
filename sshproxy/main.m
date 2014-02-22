#import <Foundation/Foundation.h>
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "DDFileLogger.h"
#import "WhitelistHelper.h"
#import "AppController.h"

@interface OWProxyModeAllSitesTransformer : NSValueTransformer

@end

static void install_signal_handlers();

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
        install_signal_handlers();
        
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


#pragma mark - Uncaught exceptions

static void signal_handler(int signalKey)
{
    //	NSSetUncaughtExceptionHandler(NULL);
	signal(SIGHUP, SIG_DFL);
	signal(SIGINT, SIG_DFL);
	signal(SIGQUIT, SIG_DFL);
	signal(SIGTRAP, SIG_DFL);
	signal(SIGILL, SIG_DFL);
	signal(SIGABRT, SIG_DFL);
	signal(SIGEMT, SIG_DFL);
	signal(SIGFPE, SIG_DFL);
	signal(SIGBUS, SIG_DFL);
	signal(SIGSEGV, SIG_DFL);
	signal(SIGSYS, SIG_DFL);
	signal(SIGPIPE, SIG_DFL);
	signal(SIGALRM, SIG_DFL);
	signal(SIGTERM, SIG_DFL);
	signal(SIGXCPU, SIG_DFL);
	signal(SIGXFSZ, SIG_DFL);
	signal(SIGVTALRM, SIG_DFL);
	signal(SIGPROF, SIG_DFL);
    
    int pid = [AppController sshProcessIdentifier];
    
    if ([AppController sshProcessIdentifier] > 0) {
        kill(pid, SIGTERM);
    }
    
    kill(getpid(), signalKey);
}

static void install_signal_handlers()
{
    [AppController initSshProcessIdentifier];
    
	signal(SIGHUP, signal_handler);
	signal(SIGINT, signal_handler);
	signal(SIGQUIT, signal_handler);
	signal(SIGILL, signal_handler);
	signal(SIGTRAP, signal_handler);
	signal(SIGABRT, signal_handler);
	signal(SIGEMT, signal_handler);
	signal(SIGFPE, signal_handler);
	signal(SIGBUS, signal_handler);
	signal(SIGSEGV, signal_handler);
	signal(SIGSYS, signal_handler);
	signal(SIGPIPE, signal_handler);
	signal(SIGALRM, signal_handler);
	signal(SIGTERM, signal_handler);
	signal(SIGXCPU, signal_handler);
	signal(SIGXFSZ, signal_handler);
	signal(SIGVTALRM, signal_handler);
	signal(SIGPROF, signal_handler);
}
