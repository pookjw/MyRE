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

/*
 -_configureRootLayer:sceneTransformLayer:transformLayer:
 
 -rootLayer (-attachLayer:, context)
 -sceneTransformLayer
 -transformLayer
 -layer
 
 MRUIWindowIntegration
 MRUIWindowSceneIntegration
 */


@interface LayerSceneDelegate () <_UIContextBindable, CALayerDelegate>
@property (retain, nonatomic, nullable) CALayer *layer;
//@property (retain, nonatomic, nullable) CALayer *rootLayer;
//@property (retain, nonatomic, nullable) CALayer *rootLayer;
//@property (retain, nonatomic, nullable) CALayer *rootLayer;

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
        
        {
            UIWindow *keyWindow = ((UIWindow * (*)(id, SEL))objc_msgSend)(UIApplication.sharedApplication, sel_registerName("keyWindow"));
            CALayer *windowLayer;
            object_getInstanceVariable(keyWindow, "_rootLayer", &windowLayer);
            _layer.position = windowLayer.position;
            _layer.frame = ((CGRect (*)(id, SEL))objc_msgSend)(object, sel_registerName("bounds"));
            _layer.contentsRect = windowLayer.bounds;
            
//            NSNumber *separatedId = [layer valueForKeyPath:@"separatedOptions.separatedId"];
//            [layer setValue:[keyWindow.layer valueForKey:@"separatedOptions"] forKey:@"separatedOptions"];
//            [layer setValue:separatedId forKeyPath:@"separatedOptions.separatedId"];
            [_layer setValue:@{
                @"clippingPrimitive": @YES,
                @"collider": @YES,
                @"material": @YES,
                @"materialParameters": @YES,
                @"mesh": @YES,
                @"texture": @YES,
                @"transform": @YES
            } forKeyPath:@"separatedOptions.updates"];
            [_layer setValue:nil forKeyPath:@"separatedOptions.pointsPerMeter"];
            [_layer setValue:@YES forKeyPath:@"separatedOptions.enableContext"];
            assert([_layer context] != nil);
//            [layer setValue:@YES forKey:@"enableContext"];
            
            [_layer setNeedsLayout];
            [CATransaction flush];
            struct RETransformService *transformService = RETransformServiceFromEntity([_layer _careEntity]);
            RETransformServiceGetWorldMatrix4x4F(transformService, [_layer _careEntity]);
            RETransformServiceGetParentWorldMatrix4x4F(transformService, [_layer _careEntity]);
            
            {
                struct REComponent *layerGeometry = REEntityGetOrAddComponentByClass([_layer _careEntity], REUILayerGeometryComponentGetComponentType());
                REUILayerGeometryComponentSetWidth(layerGeometry, _layer.bounds.size.width);
                REUILayerGeometryComponentSetHeight(layerGeometry, _layer.bounds.size.width);
            }
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
    _layer = [[CALayer alloc] init];
    _layer.delegate = self;
    
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    [windowScene addObserver:self forKeyPath:@"effectiveGeometry" options:NSKeyValueObservingOptionNew context:NULL];
    
//    {
//        UIWindow *window = [[UIWindow alloc] initWithWindowScene:windowScene];
//        [window makeKeyAndVisible];
//        [_layer release];
//        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:window.layer requiringSecureCoding:YES error:NULL];
//        assert(data != nil);
//        [window release];
//        _layer = [NSKeyedUnarchiver unarchivedObjectOfClass:[CALayer class] fromData:data error:NULL];
//        [_layer retain];
//        assert(_layer != nil);
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
    
    REEntityAddComponentByClass([layer _careEntity], REAudioPlayerComponentGetComponentType());
    
    //    CALayer *layer = window.layer;
    //    CALayer *layer = _la
    
    UIWindow *keyWindow = ((UIWindow * (*)(id, SEL))objc_msgSend)(UIApplication.sharedApplication, sel_registerName("keyWindow"));
    CALayer *windowLayer;
    object_getInstanceVariable(keyWindow, "_rootLayer", &windowLayer);
    windowLayer = keyWindow.layer;
    assert(windowLayer != nil);
    layer.transform = windowLayer.transform;
    layer.affineTransform = windowLayer.affineTransform;
    layer.position = windowLayer.position;
    layer.zPosition = windowLayer.zPosition;
    layer.anchorPointZ = windowLayer.anchorPointZ;
    layer.anchorPoint = windowLayer.anchorPoint;
    layer.frame = ((CGRect (*)(id, SEL))objc_msgSend)(windowScene, sel_registerName("bounds"));
//    layer.contentsRect = layer.bounds;
    layer.masksToBounds = NO;
    assert([layer valueForKey:@"separatedOptions"] != nil);
//    [layer setValue:nil forKeyPath:@"separatedOptions.pointsPerMeter"];
//    [layer setValue:@YES forKeyPath:@"separatedOptions.enableContext"];
//    layer.contentsRect = layer.bounds;
    {
        CALayer *sublayer = [[CALayer alloc] init];
        [sublayer setValue:@1360 forKeyPath:@"separatedOptions.pointsPerMeter"];
        [layer addSublayer:sublayer];
        sublayer.separatedState = 1;
//        REEntityInsertChild([layer _careEntity], [sublayer _careEntity], 0);
        
        sublayer.frame = layer.bounds;
//        sublayer.contentsRect = sublayer.frame;
        sublayer.backgroundColor = UIColor.greenColor.CGColor;
        sublayer.masksToBounds = NO;
        
        CALayer *windowLayer = keyWindow.layer;
        sublayer.transform = windowLayer.transform;
        sublayer.affineTransform = windowLayer.affineTransform;
        sublayer.position = windowLayer.position;
        sublayer.zPosition = windowLayer.zPosition;
        sublayer.anchorPointZ = windowLayer.anchorPointZ;
        sublayer.anchorPoint = windowLayer.anchorPoint;
        
        [sublayer release];
    }
    
//    [layer setValue:@(1360) forKeyPath:@"separatedOptions.pointsPerMeter"];
//    [layer setValue:@(NO) forKeyPath:@"separatedOptions.clipsToBounds"];
//    [layer setValue:@(CGRectMake(0., 0., 1280, 720)) forKeyPath:@"separatedOptions.clippingExtents.min"];
//    [layer setValue:@(CGRectMake(0., 0., 1280, 720)) forKeyPath:@"separatedOptions.clippingExtents.max"];
//    assert([layer valueForKeyPath:@"separatedOptions.clippingExtents.min"] != nil);
    
    layer.masksToBounds = NO;
    
//    [layer setValue:@{
//        @"backBevel" : @0,
//        @"flatDepth" : @0,
//        @"frontBevel" : @0.01
//    } forKeyPath:@"separatedOptions.geometry"];
//    [layer setValue:@0.01 forKeyPath:@"separatedOptions.separatedThickness"];
//    [layer setValue:@1 forKeyPath:@"separatedOptions.zAnchor"];
//    [layer setValue:@{
//        @"enabled": @YES,
//        @"fakeFresnelMaxDist": @"0.004",
//        @"fakeFresnelStrength": @"0.06",
//        @"fillSpecularExponent": @12,
//        @"fillSpecularStrength": @"0.3",
//        @"frontDepthForNormals": @"1.25",
//        @"mainSpecularExponent": @15,
//        @"mainSpecularStrength": @"0.4"
//    } forKeyPath:@"separatedOptions.platter"];
//    [layer setValue:@0 forKeyPath:@"thicknessAnchor"];
//    NSNumber *separatedId = [layer valueForKeyPath:@"separatedOptions.separatedId"];
//    [layer setValue:[keyWindow.layer valueForKey:@"separatedOptions"] forKey:@"separatedOptions"];
//    [layer setValue:separatedId forKeyPath:@"separatedOptions.separatedId"];
//    [layer setValue:@{
//        @"clippingPrimitive": @YES,
//        @"collider": @YES,
//        @"material": @YES,
//        @"materialParameters": @YES,
//        @"mesh": @YES,
//        @"texture": @YES,
//        @"transform": @YES
//    } forKeyPath:@"separatedOptions.updates"];
    
    layer.opacity = 1.f;
    layer.hidden = NO;
    NSLog(@"%ld", layer.separatedState);
//    layer.separatedState = 1;
    layer.backgroundColor = UIColor.systemRedColor.CGColor;
//    layer.contents = (id)[UIImage systemImageNamed:@"xmark"].CGImage;
//    layer.rasterizationScale = 2.0;
    assert(layer != nil);
//    assert(layer == _layer);
    assert(((void * (*)(id, SEL))objc_msgSend)(layer, sel_registerName("_careScene")) != NULL);
    
    {
        struct REComponent *layerGeometry = REEntityGetOrAddComponentByClass([layer _careEntity], REUILayerGeometryComponentGetComponentType());
        REUILayerGeometryComponentSetWidth(layerGeometry, layer.bounds.size.width);
        REUILayerGeometryComponentSetHeight(layerGeometry, layer.bounds.size.width);
    }
    
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

- (void)displayLayer:(CALayer *)layer {
    
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    
}

- (void)layerWillDraw:(CALayer *)layer {
    
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    
}

- (id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event {
    return nil;
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

/*
 (lldb) po $x0
 {
     geometry =     {
         backBevel = 0;
         flatDepth = 0;
         frontBevel = "0.01";
     };
     platter =     {
         enabled = 1;
         fakeFresnelMaxDist = "0.004";
         fakeFresnelStrength = "0.06";
         fillSpecularExponent = 12;
         fillSpecularStrength = "0.3";
         frontDepthForNormals = "1.25";
         mainSpecularExponent = 15;
         mainSpecularStrength = "0.4";
     };
     pointsPerMeter = 1360;
     separatedId = 13961374189244558519;
     separatedThickness = "0.01";
     updates =     {
         clippingPrimitive = 0;
         material = 0;
         materialParameters = 0;
         mesh = 0;
         texture = 0;
         transform = 1;
     };
     zAnchor = 1;
 }
 
 {
     geometry =     {
         backBevel = 0;
         flatDepth = 0;
         frontBevel = "0.01";
     };
     minorRadius = "0.005";
     platter =     {
         enabled = 1;
         fakeFresnelMaxDist = "0.004";
         fakeFresnelStrength = "0.06";
         fillSpecularExponent = 12;
         fillSpecularStrength = "0.3";
         frontDepthForNormals = "1.25";
         mainSpecularExponent = 15;
         mainSpecularStrength = "0.4";
     };
     separatedId = 15718407061596412473;
     separatedInputID = 1;
     separatedThickness = "0.01";
     thicknessAnchor = 0;
     updates =     {
         collider = 0;
     };
     zAnchor = 1;
 }
 */
