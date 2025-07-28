//
//  CALayer+Category.mm
//  MyRE
//
//  Created by Jinwoo Kim on 7/28/25.
//

#import "CALayer+Category.h"
#include <objc/runtime.h>

namespace mr_CALayer {
    namespace separatedOptions {
        NSDictionary * (*original)(CALayer *self, SEL _cmd);
        NSDictionary *custom(CALayer *self, SEL _cmd) {
            NSMutableDictionary *mutableDictionary = [original(self, _cmd) mutableCopy];
            
            if (mutableDictionary != nil) {
                NSLog(@"%@", mutableDictionary);
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
    mr_CALayer::separatedOptions::swizzle();
}

@end
