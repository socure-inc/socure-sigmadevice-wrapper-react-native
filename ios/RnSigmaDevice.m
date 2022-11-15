#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(RnSigmaDevice, NSObject)

RCT_EXTERN_METHOD(fingerprint:(NSDictionary *)config
                  options:(NSDictionary *)options
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

@end
