//
//  UIView+Category.m
//  MyRE
//
//  Created by Jinwoo Kim on 7/23/25.
//

#import "UIView+Category.h"
#include <objc/runtime.h>
#import <UIKitPrivate/UIKitPrivate.h>
#import <CoreRE/CoreRE.h>

namespace mr_UIView {
    namespace _requestSeparatedState_withReason_ {
        void (*original)(UIView *self, SEL _cmd, NSInteger separatedState, NSString *reason);
        void custom(UIView *self, SEL _cmd, NSInteger separatedState, NSString *reason) {
            /*
             self = x20
             separatedState = x21
             reason = x19
             */
            [reason retain];
            // x23
            UITraitCollection *traitCollection = [self.traitCollection retain];
            // x22
            BOOL supportsSeparation = [UIView _supportsSeparationForIdiom:traitCollection.userInterfaceIdiom];
            [traitCollection release];
            
            if (!supportsSeparation) {
                // <+184>
                /* LOG */
                // <+1168>
                [reason release];
                return;
            }
            
            BOOL isDeallocInitiated;
            {
                Ivar ivar = class_getInstanceVariable([self class], "_viewFlags");
                ptrdiff_t offset = ivar_getOffset(ivar);
                uint8_t partialFlags = *reinterpret_cast<uint8_t *>(reinterpret_cast<uintptr_t>(self) + offset) + 0x1;
                isDeallocInitiated = ((partialFlags & 0b10) == 0b10);
            }
            
            if (isDeallocInitiated) {
                // <+340>
                /* LOG */
                // <+1168>
                [reason release];
                return;
            }
            
            // <+136>
            if (separatedState == 0x2) {
                // <+580>
                // x21
                NSMutableArray<NSString *> *trackedRequestReasons = [[self _separatedStateTrackedRequestReasons] retain];
                [trackedRequestReasons addObject:reason];
                [trackedRequestReasons release];
                // x21
                NSMutableArray<NSString *> *separatedRequestReasons = [[self _separatedStateSeparatedRequestReasons] retain];
                [separatedRequestReasons removeObject:reason];
                [separatedRequestReasons release];
                // <+636>
            } else if (separatedState == 0x1) {
                // <+524>
                // x21
                NSMutableArray<NSString *> *trackedRequestReasons = [[self _separatedStateTrackedRequestReasons] retain];
                [trackedRequestReasons removeObject:reason];
                [trackedRequestReasons release];
                // x21
                NSMutableArray<NSString *> *separatedRequestReasons = [[self _separatedStateSeparatedRequestReasons] retain];
                [separatedRequestReasons addObject:reason];
                // <+632>
                [separatedRequestReasons release];
            } else if (separatedState != 0x0) {
                // <+636>
                // nop
            } else {
                // <+156>
                NSMutableArray<NSString *> *trackedRequestReasons = [[self _separatedStateTrackedRequestReasons] retain];
                [trackedRequestReasons removeObject:reason];
                // <+604>
                [trackedRequestReasons release];
                // x21
                NSMutableArray<NSString *> *separatedRequestReasons = [[self _separatedStateSeparatedRequestReasons] retain];
                [separatedRequestReasons removeObject:reason];
                [separatedRequestReasons release];
                // <+636>
            }
            
            // <+636>
            // x21
            NSInteger currentSeparatedState_1 = self._currentSeparatedState;
            NSMutableArray<NSString *> *separatedRequestReasons = [[self _separatedStateSeparatedRequestReasons] retain];
            // x23
            NSUInteger count = separatedRequestReasons.count;
            [separatedRequestReasons release];
            
            // <+676>
            if (count == 0) {
                // <+704>
                NSMutableArray<NSString *> *trackedRequestReasons = [[self _separatedStateTrackedRequestReasons] retain];
                // x23
                NSUInteger count = trackedRequestReasons.count;
                [trackedRequestReasons release];
                // <+732>
                NSInteger currentSeparatedState_2 = self._currentSeparatedState;
                if (count == 0) {
                    // <+756>
                    if (currentSeparatedState_2 == 0) {
                        // <+792>
                    } else {
                        // <+764>
                        self.layer.separatedState = 0;
                        // <+792>
                    }
                } else if (currentSeparatedState_2 == 0x2) {
                    // <+792>
                } else {
                    // <+764>
                    self.layer.separatedState = 1;
                    // <+792>
                }
            } else if (self._currentSeparatedState == 0x1) {
                // <+792>
            } else {
                // <+696>
                // <+764>
                self.layer.separatedState = 2;
                // <+792>
            }
            
            // <+792>
            NSInteger currentSeparatedState_2 = self._currentSeparatedState;
            if (currentSeparatedState_1 == currentSeparatedState_2) {
                // <+1168>
                // nop
            } else {
                // currentSeparatedState_2 = x22
                
                BOOL flag; // YES = <+976>~<+1128> / NO = <+1128>~
                if ((currentSeparatedState_2 - 1) > 0x1) {
                    // <+1128>
                    flag = NO;
                } else if (!self._supportsEntityHitTesting) {
                    // <+976>
                    flag = YES;
                } else {
                    // <+836>
                    // x23
                    id _Nullable separatedValue = [[self _separatedValueForKey:@"separatedInputID"] retain];
                    
                    // x3
                    unsigned int number;
                    if (separatedValue == nil) {
                        // <+892>
                        static unsigned int c = 0;
                        c += 1;
                        // x24
                        number = c;
                        // x25
                        NSNumber *value = [[NSNumber numberWithUnsignedInt:number] retain];
                        [self _setSeparatedValue:value forKey:@"separatedInputID"];
                        [value release];
                        // x0 = [UIView class]
                        // x2 = self
                        // <+968>
                    } else {
                        // <+864>
                        // x24 = [UIView class]
                        number = static_cast<NSNumber *>(separatedValue).unsignedIntValue;
                        // x0 = [UIView class]
                        // x2 = self
                        // <+968>
                    }
                    
                    // <+968>
                    [UIView _setSeparatedViewForServerID:self serverID:number];
                    // <+976>
                    flag = YES;
                }
                
                if (flag) {
                    // <+976>
                    // x24
                    CALayer *layer = [self.layer retain];
                    // x23
                    struct REComponent * _Nullable component = RECALayerGetCALayerClientComponent(layer);
                    [layer release];
                    
                    if (component != NULL) {
                        // <+1008>
                        // x23
                        struct REEntity *entity = REComponentGetEntity(component);
                        RECALayerClientComponentSetShouldSyncToRemotes(entity, YES);
                    }
                    
                    // <+1028>
                    [self _setSeparatedValue:@NO forKey:@"updates.collider"];
                    [self _setSeparatedValue:@1 forKey:@"zAnchor"];
                    [self _setSeparatedValue:@0 forKey:@"thicknessAnchor"];
                    
                    if (currentSeparatedState_2 == 0x1) {
                        self._thickness = [[self class] _defaultThickness];
                    }
                }
                
                // <+1128>
#warning TODO (Direct Method)
                // -[UIView _updatePlatterGroundingShadow]
                if ((currentSeparatedState_1 == 0x1) && (self._thickness > 0.)) {
                    [self _didChangePreferredContentDepth];
                }
                
                // <+1168>
            }
            
            // <+1168>
            [reason release];
        }
        void swizzle() {
            Method method = class_getInstanceMethod([UIView class], sel_registerName("_requestSeparatedState:withReason:"));
            original = reinterpret_cast<decltype(original)>(method_getImplementation(method));
            method_setImplementation(method, reinterpret_cast<IMP>(custom));
        }
    }
}

@implementation UIView (Category)

+ (void)load {
    mr_UIView::_requestSeparatedState_withReason_::swizzle();
}

@end
