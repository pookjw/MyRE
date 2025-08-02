//
//  BasicViewController.m
//  MyRE
//
//  Created by Jinwoo Kim on 7/21/25.
//

#import "BasicViewController.h"
#import <MRUIKit/MRUIKit.h>
#import <CoreRE/CoreRE.h>
#import <UIKitPrivate/UIKitPrivate.h>
#include <simd/simd.h>
#import "Utils.h"

@implementation BasicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view _requestSeparatedState:1 withReason:@"_UIViewSeparatedStateRequestReasonUnspecified"];
    
    struct REEntity *entity = [self.view _reEntity];
    struct REEntity *customEntity = REEntityCreate();
    
    REEntitySetName(customEntity, "Custom Name!");
    REEntityInsertChild(entity, customEntity, 1);
    
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
    REAssetSetNetworkSharingMode(assetHandle, NO);
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
        struct REComponent *transformComponent = REEntityGetOrAddComponentByClass(customEntity, RETransformComponentGetComponentType());
        RETransformComponentSetLocalScale(transformComponent, simd_make_float3(0.4f, 0.4f, 0.4f));
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
    
    RERelease(customEntity);
}

- (void)viewDidMoveToWindow:(UIWindow *)window shouldAppearOrDisappear:(BOOL)shouldAppearOrDisappear {
    [super viewDidMoveToWindow:window shouldAppearOrDisappear:shouldAppearOrDisappear];
    
    if (window) {
        NSLog(@"%@", MR_REEntityGetRichDebugDescriptionRecursive([self.view.window reEntity]));
    }
}

@end
