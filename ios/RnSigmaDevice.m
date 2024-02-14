#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(RnSigmaDevice, NSObject)

RCT_EXTERN_METHOD(processDevice:(NSString *)context
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(initializeSDK:(NSString *)sdkKey
                  options:(NSDictionary *)options
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

@end
