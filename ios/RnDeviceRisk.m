#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(RnDeviceRisk, NSObject)

RCT_EXTERN_METHOD(toggleUserConsent:(BOOL *)newState)

RCT_EXTERN_METHOD(setTracker:(NSString)key withTrackers:(NSArray)trackers
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(sendData:(RCTPromiseResolveBlock)resolve withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(sendDataWithContext:(NSString *)context resolve:(RCTPromiseResolveBlock)resolve withRejecter:(RCTPromiseRejectBlock)reject)

@end
