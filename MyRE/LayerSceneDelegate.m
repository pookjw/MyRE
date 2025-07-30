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
#import <QuartzCorePrivate/QuartzCorePrivate.h>
#import <FrontBoardServices/FrontBoardServices.h>
#import "Utils.h"
#include <objc/message.h>
#include <objc/runtime.h>

@interface LayerSceneDelegate () <_UIContextBindable, MRUIRealityKitSimulationEventSourceObserver, MRUIEntityPreferenceHostDelegate, MRUIEntityTraitDelegate>
@property (retain, nonatomic, nullable) CALayer *layer;
@property (weak, nonatomic, nullable) UIWindowScene *windowScene;
@property (retain, nonatomic, nullable) MRUIEntityPreferenceHost *entityPreferenceHost;
@property (retain, nonatomic, nullable) MRUIEntityTraitEnvironment *traitEnvironment;
@end

@implementation LayerSceneDelegate
@synthesize _boundContext;
@synthesize _contextBinder;

- (void)dealloc {
    [[MRUIRealityKitSimulationEventSource sharedInstance] removeObserver:self];
    [_window release];
    
    UIWindowScene *windowScene = _windowScene;
    if (windowScene) {
        [windowScene removeObserver:self forKeyPath:@"effectiveGeometry"];
    }
    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"effectiveGeometry"]) {
        _layer.frame = ((UIWindowScene *)object).bounds;
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
    
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    if (self.windowScene != nil) {
        [self.windowScene removeObserver:self forKeyPath:@"effectiveGeometry"];
    }
    self.windowScene = windowScene;
    [windowScene addObserver:self forKeyPath:@"effectiveGeometry" options:NSKeyValueObservingOptionNew context:NULL];
    
    _UIContextBinder *contextBinder = [windowScene _contextBinder];
    id<_UIContextBinding> substrate = contextBinder.substrate;
    CAContext *context = [_UIContextBinder createContextForBindable:self withSubstrate:substrate];
    struct RECALayerService *layerService = MRUIDefaultLayerService();
    
    [context orderAbove:0];
    context.commitPriority = 100;
    [substrate attachContext:context];
    assert(context != nil);
    
    struct REEntity *contextEntity = REEntityCreate();
    
    UIWindowScene *hostingScene = (UIWindowScene *)([windowScene _windowHostingScene]);
    struct REScene *reScene = hostingScene.reScene;
    assert(reScene != NULL);
    RESceneAddEntity(reScene, contextEntity);
    
    MRUIApplyBaseConfigurationToNewEntity(contextEntity);
    REEntitySetName(contextEntity, "My CALayerEntity");
    
    [[MRUIRealityKitSimulationEventSource sharedInstance] addObserver:self forEntity:contextEntity];
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
    
    MRUIEntityPreferenceHost *entityPreferenceHost = [MRUIEntityPreferenceHost preferenceHostForEntity:contextEntity];
    entityPreferenceHost.delegate = self;
    self.entityPreferenceHost = entityPreferenceHost;
    
    CALayer *layer = RECALayerComponentGetCALayer(caLayerComponent);
    RERelease(caLayerComponent);
    assert(layer == _layer);
    
    REEntityAddComponentByClass([layer _careEntity], REAudioPlayerComponentGetComponentType());
    
    layer.frame = windowScene.bounds;
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
    assert([layer _careScene] != NULL);
    
    {
        MRUIEntityTraitEnvironment *traitEnvironment = [MRUIEntityTraitEnvironment traitEnvironmentForEntity:[layer _careEntity]];
        traitEnvironment.delegate = self;
        self.traitEnvironment = traitEnvironment;
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
            RECGColorToColorGamut(UIColor.cyanColor.CGColor, &colorGamut4F, &flag);
            REMaterialParameterBlockValueSetColor4(materialParameter, "baseColorTint", flag, &colorGamut4F);
            
            struct REComponent *component = REEntityAddComponentByClass(customEntity, REMaterialParameterBlockArrayComponentGetComponentType());
            REMaterialParameterBlockArrayComponentSetBlockValueAtIndex(component, 0, materialParameter);
        }
        
        REEntityAddComponentByClass(customEntity, RENetworkComponentGetComponentType());
        RERelease(customEntity);
    }
    
    RERelease(contextEntity);
}

- (void)didReceiveEntityEvent:(MRUIEntityEvent *)event {
    NSLog(@"%@", event);
}

- (MRUIEntityPreferenceHost *)overridePreferenceHostForEntity:(struct REEntity *)entity {
    return nil;
}

- (UITraitCollection *)overrideTraitCollectionForChildEntity:(struct REEntity *)childEntity ofEntity:(struct REEntity *)entity {
    return nil;
}

- (void)traitCollectionDidChange:(id)traitCollection forEntity:(struct REEntity *)entity {
    
}

- (struct UIContextBindingDescription)_bindingDescription {
    id screen = ((id (*)(id, SEL))objc_msgSend)(self.windowScene, @selector(screen));
    FBSDisplayIdentity *displayIdentity = ((id (*)(id, SEL))objc_msgSend)(screen, @selector(displayIdentity));
    struct UIContextBindingDescription description = {
        .displayIdentity = displayIdentity,
        .ignoresHitTest = NO,
        .shouldCreateContextAsSecure = YES,
        .shouldUseRemoteContext = YES,
        .alwaysGetsContexts = NO,
        .isWindowServerHostingManaged = YES,
        .keepContextInBackground = NO,
        .allowsOcclusionDetectionOverride = NO,
        .wantsSuperlayerSecurityAnalysis = NO
    };
    
    return description;
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
