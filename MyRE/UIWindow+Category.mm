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

namespace _configureRootLayer_sceneTransformLayer_transformLayer_ {
void (*original)(UIWindow *self, SEL _cmd, CALayer *rootLayer, CALayer *sceneTransformLayer, CALayer *transformLayer);
void custom(UIWindow *self, SEL _cmd, CALayer *rootLayer, CALayer *sceneTransformLayer, CALayer *transformLayer) {
    original(self, _cmd, rootLayer, sceneTransformLayer, transformLayer);
    
    if (self.class == [UIWindow class]) {
//        NSLog(@"%@", NSStringFromCGRect(sceneTransformLayer.frame));
//        //        [transformLayer setHidden:YES];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            assert(transformLayer.sublayers.count == 1);
//            assert(transformLayer.sublayers[0] == self.layer);
//            NSLog(@"%@", self.layer);
//            NSLog(@"");
//            //            for (CALayer *sublayer in self.layer.sublayers) {
//            //                NSLog(@"%@", sublayer);
//            //                sublayer.hidden = YES;
//            //            }
//        });
        
        CALayer *windowLayer;
        object_getInstanceVariable(self, "_rootLayer", (void **)&windowLayer);
        
        struct REEntity *contextEntity = [self _contextEntity];
        struct REComponent *layerComponent = REEntityGetComponentByClass(contextEntity, RECALayerClientComponentGetComponentType());
        assert(windowLayer == RECALayerComponentGetCALayer(layerComponent));
    }
    //    
    //    if ([self _contextEntity] != NULL) {
    //        struct REComponent *caLayerComponent = REEntityGetComponentByClass([self _contextEntity], RECALayerClientComponentGetComponentType());
    //        CALayer *contextLayer = RECALayerComponentGetCALayer(caLayerComponent);
    //        
    //        NSLog(@"%@ %@ %@ %@ %@ %@", self, contextLayer, self.layer, rootLayer, sceneTransformLayer, transformLayer);
    //    }
}
void swizzle(void) {
    Method method = class_getInstanceMethod([UIWindow class], sel_registerName("_configureRootLayer:sceneTransformLayer:transformLayer:"));
    original = reinterpret_cast<decltype(original)>(method_getImplementation(method));
    method_setImplementation(method, reinterpret_cast<IMP>(custom));
}
}

namespace _transformLayerRotationsAreEnabled {
BOOL (*original)(Class self, SEL _cmd);
BOOL custom(Class self, SEL _cmd) {
    return YES;
}
void swizzle() {
    Method method = class_getClassMethod([UIWindow class], sel_registerName("_transformLayerRotationsAreEnabled"));
    original = reinterpret_cast<decltype(original)>(method_getImplementation(method));
    method_setImplementation(method, reinterpret_cast<IMP>(custom));
}
}

}


namespace mr_UITextEffectsWindow {

namespace _mrui_setFrame_ {
void (*original)(__kindof UIWindow *self, SEL _cmd, CGRect frame);
void custom(__kindof UIWindow *self, SEL _cmd, CGRect frame) {
//    [self setHidden:YES];
    NSLog(@"%@", self);
}
void swizzle() {
    Method method = class_getInstanceMethod(objc_lookUpClass("UITextEffectsWindow"), sel_registerName("_mrui_setFrame:"));
    original = reinterpret_cast<decltype(original)>(method_getImplementation(method));
    method_setImplementation(method, reinterpret_cast<IMP>(custom));
}
}

}

@implementation UIWindow (Category)

+ (void)load {
    mr_UIWindow::_setupContextLayerComponent::swizzle();
//    mr_UIWindow::_configureRootLayer_sceneTransformLayer_transformLayer_::swizzle();
//    mr_UIWindow::_transformLayerRotationsAreEnabled::swizzle();
//    mr_UITextEffectsWindow::_mrui_setFrame_::swizzle();
}

@end

/*
 contextLayer
 
 */
