#include <UIKit/UIKit.h>
#include <objc/runtime.h>
#include <dlfcn.h>


@interface TSRevealLoader : NSObject

@end

@implementation TSRevealLoader

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static TSRevealLoader *_sharedInstance;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });

    return _sharedInstance;
}

- (void)show
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"IBARevealRequestStart" object:nil];
}

@end

%ctor {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	NSDictionary *pref = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.todayios-cydia.tsrevealloader.plist"];
	NSString *dylibPath = @"/Library/Frameworks/RevealServer.framework/RevealServer";

	if (![[NSFileManager defaultManager] fileExistsAtPath:dylibPath]) {
		NSLog(@"FLEXLoader dylib file not found: %@", dylibPath);
		return;
	} 

	NSString *keyPath = [NSString stringWithFormat:@"TSRevealEnabled-%@", [[NSBundle mainBundle] bundleIdentifier]];
	if ([[pref objectForKey:keyPath] boolValue]) {
		void *handle = dlopen([dylibPath UTF8String], RTLD_NOW);
		if (handle == NULL) {
			char *error = dlerror();
			NSLog(@"Load TSRevealLoader dylib fail: %s", error);
			return;
		} 
		[[NSNotificationCenter defaultCenter] addObserver:[TSRevealLoader sharedInstance] 
										selector:@selector(show) 
										name:UIApplicationDidBecomeActiveNotification 
										object:nil];
        NSLog(@"TSRevealLoader loaded %@ successed, handle %p", dylibPath,handle);
	}	

	[pool drain];
}
