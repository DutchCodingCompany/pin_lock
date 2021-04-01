#import "PinLockPlugin.h"
#if __has_include(<pin_lock/pin_lock-Swift.h>)
#import <pin_lock/pin_lock-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "pin_lock-Swift.h"
#endif

@implementation PinLockPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPinLockPlugin registerWithRegistrar:registrar];
}
@end
