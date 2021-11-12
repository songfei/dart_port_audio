#import "PortAudioPlugin.h"
#if __has_include(<port_audio/port_audio-Swift.h>)
#import <port_audio/port_audio-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "port_audio-Swift.h"
#endif

@implementation PortAudioPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPortAudioPlugin registerWithRegistrar:registrar];
}
@end
