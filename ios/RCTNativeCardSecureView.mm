#import "RCTNativeCardSecureView.h"

// Static-lib linkage generates the Swift interop header alongside this file
// (quoted import); use_frameworks! linkage nests it inside the compiled
// framework's public headers instead (angle-bracket import). Support both
// so consumers can choose either CocoaPods linkage mode.
#if __has_include(<ReactNativeCardSecureView/ReactNativeCardSecureView-Swift.h>)
#import <ReactNativeCardSecureView/ReactNativeCardSecureView-Swift.h>
#else
#import "ReactNativeCardSecureView-Swift.h"
#endif

@implementation RCTNativeCardSecureView {
  NativeCardSecureViewAdapter *_adapter;
}

+ (NSString *)moduleName
{
  return @"NativeCardSecureView";
}

+ (BOOL)requiresMainQueueSetup
{
  return YES;
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    _adapter = [NativeCardSecureViewAdapter new];
  }
  return self;
}

- (void)createSecureToken:(NSString *)cardId
                  resolve:(RCTPromiseResolveBlock)resolve
                   reject:(RCTPromiseRejectBlock)reject
{
  dispatch_async(dispatch_get_main_queue(), ^{
    NSString *token = [self->_adapter createSecureTokenForCardId:cardId];
    if (token == nil) {
      reject(@"TOKEN_ISSUE_FAILED", @"No se pudo crear un token para la tarjeta solicitada.", nil);
      return;
    }
    resolve(token);
  });
}

- (void)openSecureView:(NSString *)cardId
           secureToken:(NSString *)secureToken
               resolve:(RCTPromiseResolveBlock)resolve
                reject:(RCTPromiseRejectBlock)reject
{
  dispatch_async(dispatch_get_main_queue(), ^{
    __weak RCTNativeCardSecureView *weakSelf = self;
    __block BOOL promiseSettled = NO;

    [self->_adapter openSecureViewWithCardId:cardId
                                 secureToken:secureToken
                                eventHandler:^(NSDictionary<NSString *, NSString *> *event) {
      RCTNativeCardSecureView *strongSelf = weakSelf;
      if (strongSelf == nil) {
        return;
      }

      NSString *type = event[@"type"];
      NSString *eventCardId = event[@"cardId"] ?: cardId;
      if ([type isEqualToString:@"opened"]) {
        [strongSelf emitOnSecureViewOpened:@{ @"cardId": eventCardId }];
        return;
      }
      if ([type isEqualToString:@"cardDataShown"]) {
        [strongSelf emitOnCardDataShown:@{ @"cardId": eventCardId }];
        return;
      }
      if ([type isEqualToString:@"validationError"]) {
        NSString *code = event[@"code"] ?: @"TOKEN_INVALID";
        NSString *message = event[@"message"] ?: @"La solicitud no pudo validarse.";
        [strongSelf emitOnValidationError:@{
          @"cardId": eventCardId,
          @"code": code,
          @"message": message,
        }];

        if ([code isEqualToString:@"VIEW_ALREADY_PRESENTED"] && !promiseSettled) {
          promiseSettled = YES;
          reject(code, message, nil);
        }
        return;
      }
      if ([type isEqualToString:@"closed"]) {
        NSString *reason = event[@"reason"] ?: @"USER_DISMISS";
        [strongSelf emitOnSecureViewClosed:@{
          @"cardId": eventCardId,
          @"reason": reason,
        }];
        if (!promiseSettled) {
          promiseSettled = YES;
          resolve(nil);
        }
      }
    }
                                   completion:^(NSString *errorMessage) {
      if (errorMessage != nil && !promiseSettled) {
        promiseSettled = YES;
        reject(@"PRESENTATION_FAILED", errorMessage, nil);
      }
    }];
  });
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
  return std::make_shared<facebook::react::NativeCardSecureViewSpecJSI>(params);
}

@end
