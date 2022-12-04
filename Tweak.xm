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
		NSString *dylibPath = @"/Library/Frameworks/RevealServer.framework/RevealServer";
		if (![[NSFileManager defaultManager] fileExistsAtPath:dylibPath]) {
			HBLogError(@"Reveal dylib file not found: %@", dylibPath);
			return;
		} 

		NSDictionary *pref = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.todayios-cydia.tsrevealloader.plist"];

		NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
		NSArray *selectedApplications = [pref objectForKey:@"selectedApplications"];
		BOOL appEnabled = [selectedApplications containsObject:bundleIdentifier];
		HBLogInfo(@"Reveal selectedApplications:%@ contains %@", selectedApplications, bundleIdentifier);
		if (appEnabled) {
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
				HBLogInfo(@"try dlopen Reveal dylib");
				void *handle = dlopen([dylibPath UTF8String], RTLD_NOW);
				if (handle == NULL) {
					char *error = dlerror();
					HBLogError(@"Load Reveal dylib fail: %s", error);
					return;
				}

				[[TSRevealLoader sharedInstance] show];
				HBLogInfo(@"Reveal loaded %@ successed, handle %p", dylibPath,handle);
			});
		}	
	}
}
