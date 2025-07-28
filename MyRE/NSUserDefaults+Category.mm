//
//  NSUserDefaults+Category.m
//  MyRE
//
//  Created by Jinwoo Kim on 7/28/25.
//

#import "NSUserDefaults+Category.h"
#include <objc/message.h>
#include <objc/runtime.h>
#import <dlfcn.h>
#import <execinfo.h>

namespace mr_NSUserDefaults {
    namespace objectForKey_ {
        id _Nullable (*original)(NSUserDefaults *self, SEL _cmd, NSString *key);
        id _Nullable custom(NSUserDefaults *self, SEL _cmd, NSString *key) {
            void *buffer[3];
            auto count = backtrace(buffer, 3);
            
            if (count < 3) {
                return original(self, _cmd, key);
            }
            
            struct dl_info info_1;
            dladdr(buffer[1], &info_1);
            
            if (strcmp(info_1.dli_sname, "_ZN12_GLOBAL__N_18getValueEPKc") != 0) {
                return original(self, _cmd, key);
            }
            
            NSLog(@"%@", key);
            
            struct dl_info info_2;
            dladdr(buffer[2], &info_2);
            
            if (strcmp(info_2.dli_sname, "_ZN2re8Defaults9boolValueEPKc") != 0) {
                return original(self, _cmd, key);
            }
            
//            return @(YES);
            return original(self, _cmd, key);
        }
        void swizzle(void) {
            Method method = class_getInstanceMethod([NSUserDefaults class], @selector(objectForKey:));
            assert(method != NULL);
            original = reinterpret_cast<decltype(original)>(method_getImplementation(method));
            method_setImplementation(method, reinterpret_cast<IMP>(custom));
        }
    }
}

@implementation NSUserDefaults (Category)

+ (void)load {
    mr_NSUserDefaults::objectForKey_::swizzle();
}

@end
