//
//  SceneDelegate.m
//  MyRE
//
//  Created by Jinwoo Kim on 7/19/25.
//

/*
 RESphereShapeCreate
 */

#import "SceneDelegate.h"
#import "ViewController.h"
#import <MRUIKit/MRUIKit.h>
#import <CoreRE/CoreRE.h>


@interface SceneDelegate ()

@end

@implementation SceneDelegate

- (void)dealloc {
    [_window release];
    [super dealloc];
}

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    UIWindow *window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
    ViewController *viewController = [[ViewController alloc] init];
    window.rootViewController = viewController;
    [viewController release];
    self.window = window;
    [window makeKeyAndVisible];
    
    struct REEntity *entity = [window reEntity];
    struct REEntity *customEntity = REEntityCreate();
    
    REEntitySetName(customEntity, "Custom Name!");
    REEntityInsertChild(entity, customEntity, 1);
    
    struct REComponentClass *meshComponentType = REMeshComponentGetComponentType();
    NSLog(@"%s", REComponentClassGetName(meshComponentType));
    
    struct RECompoent *meshComponent = REEntityAddComponentByClass(entity, meshComponentType);
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
        
        struct RECompoent *component = REEntityAddComponentByClass(entity, REMaterialParameterBlockArrayComponentGetComponentType());
        REMaterialParameterBlockArrayComponentSetBlockValueAtIndex(component, 0, materialParameter);
    }
    
    RERelease(customEntity);
    [window release];
}

@end
