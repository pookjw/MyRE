//
//  CALayer+Category.mm
//  MyRE
//
//  Created by Jinwoo Kim on 7/28/25.
//

#import "CALayer+Category.h"
#include <objc/runtime.h>
#import <UIKit/UIKit.h>

namespace mr_CALayer {
    namespace separatedOptions {
        NSDictionary * (*original)(CALayer *self, SEL _cmd);
        NSDictionary *custom(CALayer *self, SEL _cmd) {
            NSMutableDictionary *mutableDictionary = [original(self, _cmd) mutableCopy];
            
            if (mutableDictionary != nil) {
                NSLog(@"%@", mutableDictionary);
                
//                [mutableDictionary setValue:@{
//                    @"clippingPrimitive": @YES,
//                    @"collider": @YES,
//                    @"material": @YES,
//                    @"materialParameters": @YES,
//                    @"mesh": @YES,
//                    @"texture": @YES,
//                    @"transform": @YES
//                } forKeyPath:@"updates"];
                
//                [mutableDictionary removeObjectForKey:@"pointsPerMeter"];
//                id separatedInputID = [mutableDictionary objectForKey:@"separatedInputID"];
//                [mutableDictionary removeAllObjects];
//                [mutableDictionary setValue:separatedInputID forKey:@"separatedInputID"];
//                [mutableDictionary removeObjectForKey:@"separatedId"];
//                mutableDictionary[@"separatedId"] = @0;
//                [mutableDictionary removeObjectForKey:@"zAnchor"];
//                [mutableDictionary removeObjectForKey:@"thicknessAnchor"];
//                [mutableDictionary removeObjectForKey:@"separatedInputID"];
//                [mutableDictionary removeObjectForKey:@"geometry"];
//                [mutableDictionary removeObjectForKey:@"platter"];
                
                /*
                 @"enabled": @1,
                 @"fakeFresnelMaxDist": @"0.004",
                 @"fakeFresnelStrength": @"0.06",
                 @"fillSpecularStrength": @"0.3",
                 @"frontDepthForNormals": @"1.25",
                 @"mainSpecularExponent": @15,
                 @"mainSpecularStrength": @"0.4"
                 */
                if (mutableDictionary[@"platter"] != nil){
//                    [mutableDictionary setValue:(id)UIColor.redColor.CGColor forKey:@"defocusColor"];
//                    [mutableDictionary setValue:@10 forKey:@"depthBias"];
//                    
//                    [mutableDictionary setValue:@{
//                        @"enabled": @1,
////                        @"specularFadeoutSpeed": @0
//                        @"isFakeFresnelEnabled": @YES,
//                        @"isSpecularEnabled": @YES,
//                        @"usesVCABlur": @YES,
////                        @"usesVCOnlyBlur": @YES,
//                        @"isVisibleToBlurs": @YES,
//                        @"fakeFresnelStrength": @1,
//                        @"fakeFresnelMaxDist": @0.05,
//                        @"fakeFresnelFalloff": @10,
//                        @"mainSpecularStrength": @0,
//                        @"mainSpecularExponent": @0,
//                        @"sheenMultiplier": @1,
//                        @"sheenFalloff": @10
////                        @"fakeFresnelMaxDist": @0.004,
////                        @"fakeFresnelStrength": @10,
////                        @"fillSpecularStrength": @0.3,
////                        @"frontDepthForNormals": @1.25,
////                        @"mainSpecularExponent": @15,
////                        @"mainSpecularStrength": @100.4
//                    } forKey:@"platter"];
//                    [mutableDictionary setValue:@YES forKeyPath:@"windowBreakthrough.canBreakthrough"];
//                    [mutableDictionary setValue:@YES forKeyPath:@"windowBreakthrough.isCanBreakthroughHierarchical"];
                }
                
//                [mutableDictionary setValue:@NO forKeyPath:@"separatedOptions.enableContext"];
//                [mutableDictionary removeAllObjects];
            }
            
            return [mutableDictionary autorelease];
        }
        void swizzle(void) {
            Method method = class_getInstanceMethod([CALayer class], sel_registerName("separatedOptions"));
            original = reinterpret_cast<decltype(original)>(method_getImplementation(method));
            method_setImplementation(method, reinterpret_cast<IMP>(custom));
        }
    }
}

@implementation CALayer (Category)

+ (void)load {
//    mr_CALayer::separatedOptions::swizzle();
}

@end

