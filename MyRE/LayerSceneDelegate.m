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

@interface LayerSceneDelegate () <_UIContextBindable, CALayerDelegate>
@property (retain, nonatomic, nullable) CALayer *layer;
@property (retain, nonatomic, nullable) CAContext *context;
@property (weak, nonatomic, nullable) UIWindowScene *windowScene;
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
    
    UIWindowScene *windowScene = _windowScene;
    if (windowScene) {
        [windowScene removeObserver:self forKeyPath:@"effectiveGeometry"];
    }
    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"effectiveGeometry"]) {
        _layer.frame = ((CGRect (*)(id, SEL))objc_msgSend)(object, sel_registerName("bounds"));
        [_layer setValue:@{
            @"transform": @YES
        } forKeyPath:@"separatedOptions.updates"];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    [_layer release];
    _layer = [[CALayer alloc] init];
    _layer.delegate = self;
    
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    if (self.windowScene != nil) {
        [self.windowScene removeObserver:self forKeyPath:@"effectiveGeometry"];
    }
    self.windowScene = windowScene;
    [windowScene addObserver:self forKeyPath:@"effectiveGeometry" options:NSKeyValueObservingOptionNew context:NULL];
    
    id contextBinder = [windowScene _contextBinder];
    id substrate = ((id (*)(id, SEL))objc_msgSend)(contextBinder, sel_registerName("substrate"));
    struct RECALayerService *layerService = MRUIDefaultLayerService();
    CAContext *context = ((id (*)(Class, SEL, id, id))objc_msgSend)(objc_lookUpClass("_UIContextBinder"), sel_registerName("createContextForBindable:withSubstrate:"), self, substrate);
    
    [context orderAbove:0];
    context.commitPriority = 100;
    [_context release];
    _context = [context retain];
    ((void (*)(id, SEL, id))objc_msgSend)(substrate, sel_registerName("attachContext:"), context);
    assert(context != nil);
    
    struct REEntity *contextEntity = REEntityCreate();
    
    UIWindowScene *hostingScene = ((UIWindowScene * (*)(id, SEL))objc_msgSend)(windowScene, sel_registerName("_windowHostingScene"));
    struct REScene *reScene = hostingScene.reScene;
    assert(reScene != NULL);
    RESceneAddEntity(reScene, contextEntity);
    
    MRUIApplyBaseConfigurationToNewEntity(contextEntity);
    REEntitySetName(contextEntity, "My CALayerEntity");
    
    id eventSource = ((id (*)(Class, SEL))objc_msgSend)(objc_lookUpClass("MRUIRealityKitSimulationEventSource"), sel_registerName("sharedInstance"));
    ((void (*)(id, SEL, id, struct REEntity *))objc_msgSend)(eventSource, sel_registerName("addObserver:forEntity:"), self, contextEntity);
    REEntityAddComponent(contextEntity, (struct REComponentClass *)4014);
    
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
    
    id preferenceHost = ((id (*)(Class, SEL, struct REEntity *))objc_msgSend)(objc_lookUpClass("MRUIEntityPreferenceHost"), sel_registerName("preferenceHostForEntity:"), contextEntity);
    ((void (*)(id, SEL, id))objc_msgSend)(preferenceHost, sel_registerName("setDelegate:"), self);
    
    CALayer *layer = RECALayerComponentGetCALayer(caLayerComponent);
    assert(layer == _layer);
    
    REEntityAddComponentByClass([layer _careEntity], REAudioPlayerComponentGetComponentType());
    
    layer.frame = ((CGRect (*)(id, SEL))objc_msgSend)(windowScene, sel_registerName("bounds"));
    assert([layer valueForKey:@"separatedOptions"] != nil);
    [layer setValue:@{
        @"transform": @YES
    } forKeyPath:@"separatedOptions.updates"];
    
    {
        CALayer *sublayer = [[CALayer alloc] init];
        [sublayer setValue:@1360 forKeyPath:@"separatedOptions.pointsPerMeter"];
        [layer addSublayer:sublayer];
        sublayer.separatedState = 1;
        sublayer.frame = layer.bounds;
        sublayer.backgroundColor = UIColor.greenColor.CGColor;
        
        [sublayer release];
    }
    
    layer.opacity = 1.f;
    layer.hidden = NO;
    layer.backgroundColor = UIColor.systemRedColor.CGColor;
    assert(((void * (*)(id, SEL))objc_msgSend)(layer, sel_registerName("_careScene")) != NULL);
    
    {
        id traitEnv = ((id (*)(Class, SEL, struct REEntity *))objc_msgSend)(objc_lookUpClass("MRUIEntityTraitEnvironment"), sel_registerName("traitEnvironmentForEntity:"), [layer _careEntity]);
        ((void (*)(id, SEL, id))objc_msgSend)(traitEnv, sel_registerName("setDelegate:"), self);
        [traitEnv retain];
    }
    
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
}

- (void)didReceiveEntityEvent:(id)event {
    NSLog(@"%@", event);
}


@synthesize _boundContext;
@synthesize _contextBinder;

- (struct UIContextBindingDescription)_bindingDescription {
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
    
    return [result autorelease];
}

- (CGFloat)_bindableLevel {
    return UIWindowLevelStatusBar;
}

- (CALayer *)_bindingLayer {
    return _layer;
}

- (BOOL)_isVisible {
    abort();
    return NO;
}

@end
