//
//  UIWindow+Category.m
//  MyRE
//
//  Created by Jinwoo Kim on 7/23/25.
//

#import "UIWindow+Category.h"
#include <objc/runtime.h>
#import <MRUIKit/MRUIKit.h>
#import <UIKitPrivate/UIKitPrivate.h>
#import <CoreRE/CoreRE.h>
#import <QuartzCorePrivate/QuartzCorePrivate.h>

namespace mr_UIWindow {
    namespace _setupContextLayerComponent {
        void (*original)(UIWindow *self, SEL _cmd);
        void custom(UIWindow *self, SEL _cmd) {
            // self = x20
            if ([UIApplication mrui_optsOutOfMixedRealityPreparation]) {
                return;
            }
            
            // sp + 0x8
            CAContext *boundContext = self._boundContext;
            CALayer * _Nullable layer = boundContext.layer;
            
            if (layer != nil) {
                // x19
                struct RECALayerService *layerService = MRUIDefaultLayerService();
                struct REEntity *contextEntity = [self _contextEntity];
                // x19
                struct REComponent *caLayerComponent = RECALayerServiceCreateRootComponent(layerService, boundContext, contextEntity, NULL);
                assert(REComponentGetClass(caLayerComponent) == RECALayerClientComponentGetComponentType());
                assert(REComponentGetClass(caLayerComponent) != RECALayerComponentGetComponentType());
                RECALayerComponentSetRespectsLayerTransform(caLayerComponent, [self _mrui_wantsLayerComponentRespectsLayerTransform]);
                RECALayerComponentRootSetPointsPerMeter(caLayerComponent, [self mrui_pointsPerMeter]);
                RECALayerComponentSetShouldSyncToRemotes(caLayerComponent, YES);
                // x20
                CALayer *layer = RECALayerComponentGetCALayer(caLayerComponent);
                layer.separatedState = 1;
                RECALayerClientComponentSetUpdatesMesh(caLayerComponent, NO);
                RECALayerComponentSetUpdatesMaterial(caLayerComponent, NO);
                RECALayerComponentSetUpdatesTexture(caLayerComponent, NO);
                RECALayerComponentSetUpdatesClippingPrimitive(caLayerComponent, NO);
                RERelease(caLayerComponent);
            }
            
            // <+276>
            // nop
        }
        void swizzle(void) {
            Method method = class_getInstanceMethod([UIWindow class], sel_registerName("_setupContextLayerComponent"));
            original = reinterpret_cast<decltype(original)>(method_getImplementation(method));
            method_setImplementation(method, reinterpret_cast<IMP>(custom));
        }
    }
}

@implementation UIWindow (Category)

+ (void)load {
    mr_UIWindow::_setupContextLayerComponent::swizzle();
}

@end
