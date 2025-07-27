//
//  LayerSceneDelegate.m
//  MyRE
//
//  Created by Jinwoo Kim on 7/26/25.
//

#import "LayerSceneDelegate.h"
#import <CoreRE/CoreRE.h>
#import <MRUIKit/MRUIKit.h>
#import <UIKitPrivate/UIKitPrivate.h>
#import "Utils.h"
#include <objc/message.h>
#include <objc/runtime.h>

@interface CustomLayer : CALayer
@end
@implementation CustomLayer
- (void)layoutSublayers {
    [super layoutSublayers];
    NSLog(@"%@", NSStringFromCGRect(self.bounds));
}
- (void)drawInContext:(CGContextRef)ctx {
    [super drawInContext:ctx];
    NSLog(@"%@", NSStringFromCGRect(self.bounds));
}
@end


@interface LayerSceneDelegate () <_UIContextBindable>
@property (retain, nonatomic, nullable) __kindof CALayer *layer;
@property (retain, nonatomic, nullable) CAContext *context;
@end

@implementation LayerSceneDelegate

+ (void)load {
    Protocol *MRUIEntityTraitDelegate = NSProtocolFromString(@"MRUIEntityTraitDelegate");
    if (MRUIEntityTraitDelegate) {
        assert(class_addProtocol(self, MRUIEntityTraitDelegate));
    }
}

- (void)dealloc {
    [_window release];
    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"effectiveGeometry"]) {
        [_layer setNeedsLayout];
        struct REComponent *component = REEntityGetComponentByClass([_layer _careEntity], RENetworkComponentGetComponentType());
        if (component != NULL) {
            RENetworkMarkComponentDirty(component);
            RENetworkMarkEntityMetadataDirty(component);
        }
        
//        {
//            struct REComponent *component = REEntityGetOrAddComponentByClass([_layer _careEntity], REUISortingComponentGetComponentType());
//            REUISortingComponentSetSortCategory(component, YES);
//            REUISortingComponentSetExtents(component, _layer.bounds);
//        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    [_layer release];
    _layer = [[CustomLayer alloc] init];
    
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    [windowScene addObserver:self forKeyPath:@"effectiveGeometry" options:NSKeyValueObservingOptionNew context:NULL];
    
////    {
//        UIWindow *window = [[UIWindow alloc] initWithWindowScene:windowScene];
//        [_layer release];
//        object_getInstanceVariable(window, "_layerRetained", &_layer);
//        [_layer retain];
////        [[windowScene _contextBinder] attachBindable:window];
//    _layer.frame = CGRectMake(0., 0., 1280., 720.);
//        _layer.hidden = NO;
//        _layer.backgroundColor = UIColor.redColor.CGColor;
//    ((void (*)(id, SEL))objc_msgSend)(window, sel_registerName("_updateTransformLayer"));
//        [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
//            ((void (*)(id, SEL))objc_msgSend)(window, sel_registerName("_updateTransformLayer"));
//        }];
//        return;
//    }
//        [[windowScene _contextBinder] attachBindable:window];
//        window.backgroundColor = [UIColor.redColor colorWithAlphaComponent:0.1];
////        [view _requestSeparatedState:1 withReason:@"_UIViewSeparatedStateRequestReasonUnspecified"];
////        view.layer.separatedState = 1;
////        assert([window.layer _careEntity] != NULL);
//        window.layer.hidden = NO;
//        window.layer.opacity = 1.f;
////        [window release];
////        REEntityInsertChild([layer _careEntity], [window.layer _careEntity], 0);
////        [window release];
////        NSLog(@"%d", (*(uint32_t *)((uintptr_t)[window.layer _careEntity] + 0x131) >> 2) & 1); // 1
////        *(uint32_t *)((uintptr_t)[window.layer _careEntity] + 0x131) &= ~0b100;
////        NSLog(@"%d", (*(uint32_t *)((uintptr_t)[window.layer _careEntity] + 0x131) >> 2) & 1); // 1
//    }
//    UIWindow *window = [[UIWindow alloc] initWithWindowScene:windowScene];
//    [[windowScene _contextBinder] attachBindable:window];
//    NSLog(@"%p", [window reEntity]);
    
    // substrate
    id contextBinder = [windowScene _contextBinder];
    id substrate = ((id (*)(id, SEL))objc_msgSend)(contextBinder, sel_registerName("substrate"));
    struct RECALayerService *layerService = MRUIDefaultLayerService();
    CAContext *context = ((id (*)(Class, SEL, id, id))objc_msgSend)(objc_lookUpClass("_UIContextBinder"), sel_registerName("createContextForBindable:withSubstrate:"), self, substrate);
//    struct RECALayerService *layerService = MRUIDefaultLayerService();
//    CAContext *context = RECALayerServiceGetOrCreateCAContext(layerService);
    [context orderAbove:0];
    context.commitPriority = 100;
    [_context release];
    _context = [context retain];
    ((void (*)(id, SEL, id))objc_msgSend)(substrate, sel_registerName("attachContext:"), context);
    assert(context != nil);
    
    struct REEntity *contextEntity = REEntityCreate();
//    struct REEntity *layerEntity = REEntityCreate();
    
    UIWindowScene *hostingScene = ((UIWindowScene * (*)(id, SEL))objc_msgSend)(windowScene, sel_registerName("_windowHostingScene"));
    struct REScene *reScene = hostingScene.reScene;
    assert(reScene != NULL);
    RESceneAddEntity(reScene, contextEntity);
    
//    REEntitySetParent(contextEntity, [hostingScene reRootEntity]);
    
    
    MRUIApplyBaseConfigurationToNewEntity(contextEntity);
    REEntitySetName(contextEntity, "CALayerEntity");
    
//    NSLog(@"%d", (*(uint32_t *)((uintptr_t)entity_1 + 0x131) >> 2) & 1); // 1
//    *(uint32_t *)((uintptr_t)entity_1 + 0x131) &= ~0b100;
//    NSLog(@"%d", (*(uint32_t *)((uintptr_t)entity_1 + 0x131) >> 2) & 1); // 1
    
    id eventSource = ((id (*)(Class, SEL))objc_msgSend)(objc_lookUpClass("MRUIRealityKitSimulationEventSource"), sel_registerName("sharedInstance"));
    ((void (*)(id, SEL, id, struct REEntity *))objc_msgSend)(eventSource, sel_registerName("addObserver:forEntity:"), self, contextEntity);
    REEntityAddComponent(contextEntity, (struct REComponentClass *)4014);
    
    struct REComponent *caLayerComponent = RECALayerServiceCreateRootComponent(layerService, context, contextEntity, NULL);
    assert(REComponentGetClass(caLayerComponent) == RECALayerClientComponentGetComponentType());
    assert(REComponentGetClass(caLayerComponent) != RECALayerComponentGetComponentType());
    RECALayerComponentSetRespectsLayerTransform(caLayerComponent, YES);
    RECALayerComponentRootSetPointsPerMeter(caLayerComponent, 1360);
    RECALayerComponentSetShouldSyncToRemotes(caLayerComponent, YES);
    RECALayerClientComponentSetUpdatesMesh(caLayerComponent, NO);
    RECALayerComponentSetUpdatesMaterial(caLayerComponent, NO);
    RECALayerComponentSetUpdatesTexture(caLayerComponent, NO);
    RECALayerComponentSetUpdatesClippingPrimitive(caLayerComponent, NO);
    NSLog(@"%@", NSStringFromCGSize(RECALayerComponentGetLayerSize(caLayerComponent)));
    
    id preferenceHost = ((id (*)(Class, SEL, struct REEntity *))objc_msgSend)(objc_lookUpClass("MRUIEntityPreferenceHost"), sel_registerName("preferenceHostForEntity:"), contextEntity);
    ((void (*)(id, SEL, id))objc_msgSend)(preferenceHost, sel_registerName("setDelegate:"), self);
    
    CALayer *layer = RECALayerComponentGetCALayer(caLayerComponent);
    assert(layer == _layer);
//    CALayer *layer = window.layer;
//    CALayer *layer = _la
    
    layer.transform = ((UIWindow * (*)(id, SEL))objc_msgSend)(UIApplication.sharedApplication, sel_registerName("keyWindow")).layer.transform;
    layer.affineTransform = ((UIWindow * (*)(id, SEL))objc_msgSend)(UIApplication.sharedApplication, sel_registerName("keyWindow")).layer.affineTransform;
    layer.position = ((UIWindow * (*)(id, SEL))objc_msgSend)(UIApplication.sharedApplication, sel_registerName("keyWindow")).layer.position;
    layer.bounds = ((UIWindow * (*)(id, SEL))objc_msgSend)(UIApplication.sharedApplication, sel_registerName("keyWindow")).layer.bounds;
    layer.frame = ((UIWindow * (*)(id, SEL))objc_msgSend)(UIApplication.sharedApplication, sel_registerName("keyWindow")).layer.frame;
    layer.zPosition = ((UIWindow * (*)(id, SEL))objc_msgSend)(UIApplication.sharedApplication, sel_registerName("keyWindow")).layer.zPosition;
    layer.bounds = ((UIWindow * (*)(id, SEL))objc_msgSend)(UIApplication.sharedApplication, sel_registerName("keyWindow")).layer.bounds;
    NSLog(@"%@", NSStringFromCGRect(layer.bounds));
    layer.opacity = 1.f;
    layer.hidden = NO;
    layer.separatedState = 1;
    layer.backgroundColor = UIColor.systemRedColor.CGColor;
//    layer.rasterizationScale = 2.0;
    assert(layer != nil);
//    assert(layer == _layer);
    assert(((void * (*)(id, SEL))objc_msgSend)(layer, sel_registerName("_careScene")) != NULL);
    
    {
        id traitEnv = ((id (*)(Class, SEL, struct REEntity *))objc_msgSend)(objc_lookUpClass("MRUIEntityTraitEnvironment"), sel_registerName("traitEnvironmentForEntity:"), [layer _careEntity]);
        ((void (*)(id, SEL, id))objc_msgSend)(traitEnv, sel_registerName("setDelegate:"), self);
        [traitEnv retain];
    }
    
    [layer setNeedsDisplay];
    [layer setNeedsLayout];
    [CATransaction commit];
    [CATransaction flush];
    
    NSLog(@"%@", [self.layer recursiveDescription]);
    
    ((void (*)(id, SEL))objc_msgSend)(layer, sel_registerName("_careMarkEntityDirtyIfHasNetworkComponent"));
//    {
//        CustomLayer *sublayer = [[CustomLayer alloc] init];
//        sublayer.opacity = 1.f;
//        sublayer.hidden = NO;
//        sublayer.separatedState = 1;
//        sublayer.backgroundColor = UIColor.systemRedColor.CGColor;
//        [layer addSublayer:sublayer];
//        sublayer.frame = layer.bounds;
////        MRUIApplyBaseConfigurationToNewEntity([sublayer _careEntity]);
//        REEntityAddComponentByClass([layer _careEntity], RENetworkComponentGetComponentType());
//        REEntityInsertChild([layer _careEntity], [sublayer _careEntity], 1);
//        
//        struct REComponent *caLayerComponent = REEntityGetComponentByClass([sublayer _careEntity], RECALayerClientComponentGetComponentType());
//        RECALayerComponentSetRespectsLayerTransform(caLayerComponent, YES);
//        RECALayerComponentSetShouldSyncToRemotes(caLayerComponent, YES);
//        RECALayerClientComponentSetUpdatesMesh(caLayerComponent, NO);
//        RECALayerComponentSetUpdatesMaterial(caLayerComponent, NO);
//        RECALayerComponentSetUpdatesTexture(caLayerComponent, NO);
//        RECALayerComponentSetUpdatesClippingPrimitive(caLayerComponent, NO);
//    }
    
    
    
//    [self.layer setNeedsDisplay];
//    [self.layer setNeedsLayout];
//    [CATransaction commit];
    
    //
    
    {
        struct REEntity *customEntity = REEntityCreate();
        REEntityInsertChild([_layer _careEntity], customEntity, 0);
        
        struct REComponentClass *meshComponentType = REMeshComponentGetComponentType();
        
        struct REComponent *meshComponent = REEntityAddComponentByClass(customEntity, meshComponentType);
        assert(meshComponent != nil);
        
        struct REEngine *engine = REEngineGetShared();
        struct REServiceLocator *serviceLocator = REEngineGetServiceLocator(engine);
        struct REAssetManager *assetManager = REServiceLocatorGetAssetManager(serviceLocator);
        assert(assetManager != NULL);
        
        struct REGeomBuildSphereOptions options = REGeomBuildSphereDefaultOptions();
        options.value0 = 0x40;
        options.radius = 0.1f;
        options.value1 = 0x101;
        struct REAssetLoadDescriptor *descriptor = REMeshAssetCreateSphereDescriptor(assetManager, options, false);
        struct REAssetHandle *assetHandle = REAssetHandleCreateNewMutableWithAssetDescriptors(assetManager, &descriptor, 1);
        RERelease(descriptor);
        REAssetHandleLoadNow(assetHandle);
        REAssetSetNetworkSharingMode(assetHandle, false);
        REMeshComponentSetMesh(meshComponent, assetHandle);
        RERelease(assetHandle);
        
        {
            // alpha가 0보다 작으면 engine:transparentSimple.rematerial
            // 아니면 engine:simple.rematerial
            // CGColorGetAlpha
            struct REAsset *materialAsset = REAssetManagerCreateAssetHandle(assetManager, "engine:transparentSimple.rematerial");
            REMeshComponentAddMaterial(meshComponent, materialAsset);
            RERelease(materialAsset);
        }
        
        {
            struct REMaterialParameter *materialParameter = REMaterialParameterBlockValueCreate();
            REMaterialParameterBlockValueClearParameter(materialParameter);
            REMaterialParameterBlockValueSetFloat(materialParameter, "roughnessScale", 0.f);
            REMaterialParameterBlockValueSetFloat(materialParameter, "metallicScale", 1.f);
            struct REColorGamut4F colorGamut4F;
            unsigned int flag;
            RECGColorToColorGamut(UIColor.redColor.CGColor, &colorGamut4F, &flag);
            REMaterialParameterBlockValueSetColor4(materialParameter, "baseColorTint", flag, &colorGamut4F);
            
            struct REComponent *component = REEntityAddComponentByClass(customEntity, REMaterialParameterBlockArrayComponentGetComponentType());
            REMaterialParameterBlockArrayComponentSetBlockValueAtIndex(component, 0, materialParameter);
        }
        
        {
            REEntityAddComponentByClass(customEntity, RENetworkComponentGetComponentType());
        }
    }
    
    NSLog(@"%@", MR_REEntityGetRichDebugDescriptionRecursive([_layer _careEntity]));
    NSLog(@"%@", MRUIEntityViewLayerRecursiveDescription([layer _careEntity], nil, layer, @"-", 0, YES));
    
    
//    NSLog(@"%@", ((id (*)(id, SEL))objc_msgSend)(scene, sel_registerName("_synchronizedDrawingFence")));
}

- (void)didReceiveEntityEvent:(id)event {
    NSLog(@"%@", event);
    
    struct REEntity *entity = ((struct REEntity * (*)(id,SEL))objc_msgSend)(event, sel_registerName("entity"));
    assert(REEntityIsVisible(entity));
    
//    [self.layer setNeedsDisplay];
//    [self.layer setNeedsLayout];
//    [CATransaction commit];
//    [CATransaction flush];
}

@synthesize _boundContext;
@synthesize _contextBinder;

- (struct UIContextBindingDescription)_bindingDescription {
//    struct UIContextBindingDescription description = {
//        .displayIdentity
//    };
//    return description;
    UIWindow *keyWindow = ((id (*)(id, SEL))objc_msgSend)(UIApplication.sharedApplication, sel_registerName("keyWindow"));
    struct UIContextBindingDescription result = ((struct UIContextBindingDescription (*)(id, SEL))objc_msgSend)(keyWindow, _cmd);
    return result;
}
- (NSDictionary *)_contextOptionsWithInitialOptions:(NSDictionary *)options {
    NSMutableDictionary *result = [options mutableCopy];
    
    // disassembly of -[UIWindow(MRUIKit) _configureContextOptions:]
    [(NSDictionary *)RECAContextCreateDefaultOptions(NULL) enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [result setObject:obj forKey:key];
    }];
//    result[@"displayable"] = @YES;
    return [result autorelease];
}
- (CGFloat)_bindableLevel {
    UIWindow *keyWindow = ((id (*)(id, SEL))objc_msgSend)(UIApplication.sharedApplication, sel_registerName("keyWindow"));
    return keyWindow.windowLevel;
}
- (CALayer *)_bindingLayer {
    return _layer;
}

- (BOOL)_isVisible {
    abort();
    return NO;
}

@end
