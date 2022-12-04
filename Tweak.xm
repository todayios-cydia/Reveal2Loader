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
	@autoreleasepool {
		NSString *dylibPath = @"/Library/Application Support/RevealServer.framework/RevealServer";
		if (![[NSFileManager defaultManager] fileExistsAtPath:dylibPath]) {
			HBLogDebug(@"Reveal dylib file not found: %@", dylibPath);
			return;
		} 

		NSDictionary *pref = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.todayios-cydia.tsrevealloader.plist"];

		NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
		NSArray *selectedApplications = [pref objectForKey:@"selectedApplications"];
		BOOL appEnabled = [selectedApplications containsObject:bundleIdentifier];
		HBLogDebug(@"WoodPecker selectedApplications:%@ contains %@", selectedApplications, bundleIdentifier);
		if (appEnabled) {
			void *handle = dlopen([dylibPath UTF8String], RTLD_NOW);
			if (handle == NULL) {
				char *error = dlerror();
				HBLogDebug(@"Load TSRevealLoader dylib fail: %s", error);
				return;
			} 
			[[NSNotificationCenter defaultCenter] addObserver:[TSRevealLoader sharedInstance] 
											selector:@selector(show) 
											name:UIApplicationDidBecomeActiveNotification 
											object:nil];
			HBLogDebug(@"TSRevealLoader loaded %@ successed, handle %p", dylibPath,handle);
		}	
	}
}
