#import "NativeMixpanelPlugin.h"
#import <native_mixpanel/native_mixpanel-Swift.h>

@implementation NativeMixpanelPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftNativeMixpanelPlugin registerWithRegistrar:registrar];
}
@end
