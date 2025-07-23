//
//  CALayerViewController.m
//  MyRE
//
//  Created by Jinwoo Kim on 7/22/25.
//

#import "CALayerViewController.h"
#import <CoreRE/CoreRE.h>
#import <MRUIKit/MRUIKit.h>
#import <UIKitPrivate/UIKitPrivate.h>
#import "Utils.h"
#include <objc/message.h>
#include <objc/runtime.h>

@interface MyLayer : CALayer
@end
@implementation MyLayer
//@synthesize _boundContext;
//@synthesize _contextBinder;
//
//- (struct UIContextBindingDescription)_bindingDescription {
//    struct UIContextBindingDescription description = {
////        .displayIdentity
//    };
//    return description;
////    UIWindow *keyWindow = ((id (*)(id, SEL))objc_msgSend)(UIApplication.sharedApplication, sel_registerName("keyWindow"));
////    struct UIContextBindingDescription result = ((struct UIContextBindingDescription (*)(id, SEL))objc_msgSend)(keyWindow, _cmd);
////    return result;
//}
//- (NSDictionary *)_contextOptionsWithInitialOptions:(NSDictionary *)options {
//    NSMutableDictionary *result = [options mutableCopy];
//    
//    // disassembly of -[UIWindow(MRUIKit) _configureContextOptions:]
//    [(NSDictionary *)RECAContextCreateDefaultOptions(NULL) enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
//        [result setObject:obj forKey:key];
//    }];
//    
//    return [result autorelease];
//}
//- (CGFloat)_bindableLevel {
//    return UIWindowLevelAlert;
//}
//- (CALayer *)_bindingLayer {
//    return self;
//}
//- (void)_updateWindowTraits {}
//- (CGFloat)level {
//    return UIWindowLevelAlert;
//}
//-(BOOL)_hasContext {
//    return _layerContext != nil;
//}
//- (BOOL)_isVisible {
//    return YES;
//}
//- (BOOL)_canAffectStatusBarAppearance {
//    return NO;
//}
//
- (void)drawInContext:(CGContextRef)ctx {
    CGRect bounds = self.bounds;
    CGContextSetFillColorWithColor(ctx, [UIColor systemBlueColor].CGColor);
    CGContextFillEllipseInRect(ctx, bounds);
}

@end

@interface CALayerViewController ()

@end

@implementation CALayerViewController

//- (void)loadView {
//    MyView *myView = [[MyView alloc] init];
//    self.view = myView;
//    [myView release];
//}

- (void)viewDidLoad {
    [super viewDidLoad];
        [self.view _requestSeparatedState:1 withReason:@"_UIViewSeparatedStateRequestReasonUnspecified"];
        self.view.backgroundColor = [UIColor.systemBlueColor colorWithAlphaComponent:0.2];
    self.view.layer.zPosition = 30.;
}

- (void)viewDidMoveToWindow:(UIWindow *)window shouldAppearOrDisappear:(BOOL)shouldAppearOrDisappear {
    [super viewDidMoveToWindow:window shouldAppearOrDisappear:shouldAppearOrDisappear];
    
    if (window) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            struct REEntity *entity = [self.view _reEntity];
            NSLog(@"%@", MR_REEntityGetRichDebugDescriptionRecursive(entity));
            
            struct REEntity *subentity = REEntityCreate();
            MRUIApplyBaseConfigurationToNewEntity(subentity);
            REEntitySetName(subentity, "My Layer Entity");
//            REEntityInsertChild(entity, subentity, 0);
            
            struct RECALayerService *layerService = MRUIDefaultLayerService();
            CAContext *boundContext = RECALayerServiceGetOrCreateCAContext(layerService);
            NSLog(@"%p", [boundContext layer]);
            [boundContext setLevel:UIWindowLevelStatusBar];
            [boundContext setCommitPriority:1];
            {
               CAContext *boundContext = window._boundContext;
                NSLog(@"%p", boundContext);
            }
            // x19
            struct REComponent *caLayerComponent = RECALayerServiceCreateRootComponent(layerService, boundContext, subentity, NULL);
            assert(REComponentGetClass(caLayerComponent) == RECALayerClientComponentGetComponentType());
            assert(REComponentGetClass(caLayerComponent) != RECALayerComponentGetComponentType());
//            struct REComponent *caLayerComponent = REEntityAddComponentByClass(subentity, RECALayerClientComponentGetComponentType());
            RECALayerComponentSetRespectsLayerTransform(caLayerComponent, [window _mrui_wantsLayerComponentRespectsLayerTransform]);
            RECALayerComponentRootSetPointsPerMeter(caLayerComponent, [window mrui_pointsPerMeter]);
            RECALayerComponentSetShouldSyncToRemotes(caLayerComponent, YES);
            // x20
            CALayer *layer = RECALayerComponentGetCALayer(caLayerComponent);
            layer.transform = window.layer.transform;
            layer.backgroundColor = UIColor.systemRedColor.CGColor;
            //        layer.frame = CGRectMake(0., 0., 400., 400.);
            //        layer.zPosition = 0;
//            layer.separatedState = 1;
            RECALayerClientComponentSetUpdatesMesh(caLayerComponent, NO);
            RECALayerComponentSetUpdatesMaterial(caLayerComponent, NO);
            RECALayerComponentSetUpdatesTexture(caLayerComponent, NO);
            RECALayerComponentSetUpdatesClippingPrimitive(caLayerComponent, NO);
            
            RECALayerClientComponentSetShouldSyncToRemotes(subentity, YES);
//            RERelease(caLayerComponent);
            
            MyLayer *myLayer = [[MyLayer alloc] init];
            myLayer.frame = layer.bounds;
            myLayer.backgroundColor = UIColor.systemRedColor.CGColor;
//            myLayer.separatedState = 1;
            //        myLayer.zPosition = 10;
            [layer addSublayer:myLayer];
            [layer retain];
            [layer setNeedsLayout];
            [myLayer setNeedsLayout];
            [layer setNeedsDisplay];
            [myLayer setNeedsDisplay];
            
            assert(((BOOL (*)(id, SEL))objc_msgSend)(boundContext, sel_registerName("valid")));
            NSLog(@"%@", MR_REEntityGetRichDebugDescriptionRecursive(entity));
        });
    }
}

@end
