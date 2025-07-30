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

@interface CALayerViewController () <_UIContextBindable>
@property (retain, nonatomic, nullable) CALayer *bindingLayer;
@end

@implementation CALayerViewController
@synthesize _boundContext;
@synthesize _contextBinder;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CALayer *bindingLayer = [[CALayer alloc] init];
    bindingLayer.backgroundColor = UIColor.brownColor.CGColor;
    bindingLayer.hidden = NO;
    bindingLayer.opacity = 1.f;
    bindingLayer.frame = CGRectMake(300., 300., 300., 300.);
    bindingLayer.zPosition = 30.f;
    self.bindingLayer = bindingLayer;
    [bindingLayer release];
    
    [self.view _requestSeparatedState:1 withReason:@"_UIViewSeparatedStateRequestReasonUnspecified"];
}

- (UIContainerBackgroundStyle)preferredContainerBackgroundStyle {
    return UIContainerBackgroundStyleHidden;
}

- (void)viewDidMoveToWindow:(UIWindow *)window shouldAppearOrDisappear:(BOOL)shouldAppearOrDisappear {
    [super viewDidMoveToWindow:window shouldAppearOrDisappear:shouldAppearOrDisappear];
    
    UIWindowScene *windowScene = window.windowScene;
    if (windowScene != nil) {
        _UIContextBinder *contextBinder = [windowScene _contextBinder];
        id<_UIContextBinding> substrate = contextBinder.substrate;
        CAContext *context = [_UIContextBinder createContextForBindable:self withSubstrate:substrate];
        
        struct RECALayerService *layerService = MRUIDefaultLayerService();
        
        [context orderAbove:0];
        context.commitPriority = 100;
        [substrate attachContext:context];
        
        struct REEntity *contextEntity = REEntityCreate();
        MRUIApplyBaseConfigurationToNewEntity(contextEntity);
        REEntityInsertChild([self.view.layer _careEntity], contextEntity, 0);
        
        struct REComponent *caLayerComponent = RECALayerServiceCreateRootComponent(layerService, context, contextEntity, NULL);
        assert(REComponentGetClass(caLayerComponent) == RECALayerClientComponentGetComponentType());
        assert(REComponentGetClass(caLayerComponent) != RECALayerComponentGetComponentType());
        RECALayerComponentSetRespectsLayerTransform(caLayerComponent, NO);
        RECALayerComponentRootSetPointsPerMeter(caLayerComponent, 1360);
        RECALayerComponentSetShouldSyncToRemotes(caLayerComponent, YES);
        RECALayerClientComponentSetUpdatesMesh(caLayerComponent, NO);
        RECALayerComponentSetUpdatesMaterial(caLayerComponent, NO);
        RECALayerComponentSetUpdatesTexture(caLayerComponent, NO);
        RECALayerComponentSetUpdatesClippingPrimitive(caLayerComponent, NO);
        
        [self.bindingLayer setValue:@{
            @"transform": @YES
        } forKeyPath:@"separatedOptions.updates"];
        
        RERelease(caLayerComponent);
        RERelease(contextEntity);
    } else {
        REEntityRemoveFromSceneOrParent([self.bindingLayer _careEntity]);
    }
}

- (struct UIContextBindingDescription)_bindingDescription {
    return [self.view.window _bindingDescription];
}

- (NSDictionary *)_contextOptionsWithInitialOptions:(NSDictionary *)options {
    return [self.view.window _contextOptionsWithInitialOptions:options];
}

- (CGFloat)_bindableLevel { 
    return UIWindowLevelAlert;
}

- (CALayer *)_bindingLayer { 
    return self.bindingLayer;
}

- (BOOL)_isVisible { 
    abort();
}

@end
