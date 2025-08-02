//
//  ImagePresentationViewController.m
//  MyRE
//
//  Created by Jinwoo Kim on 8/2/25.
//

#import "ImagePresentationViewController.h"
#import <CoreRE/CoreRE.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKitPrivate/UIKitPrivate.h>
#import <MRUIKit/MRUIKit.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

@implementation ImagePresentationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view _requestSeparatedState:1 withReason:@"_UIViewSeparatedStateRequestReasonUnspecified"];
    
    struct REEntity *entity = [self.view _reEntity];
    struct REEntity *customEntity = REEntityCreate();
    REEntitySetParent(customEntity, entity);
    
    struct REComponent *transformComponent = REEntityGetOrAddComponentByClass(customEntity, RETransformComponentGetComponentType());
    RETransformComponentSetWorldPosition(transformComponent, simd_make_float3(0.f, 0.f, 0.1f));
    
    NSURL *url = [NSBundle.mainBundle URLForResource:@"spatial_image" withExtension:UTTypeHEIC.preferredFilenameExtension];
    assert(url != nil);
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)url, NULL);
    size_t count = CGImageSourceGetCount(imageSource);
    if (count > 0) {
        // orientation 담겨 있음
        CFDictionaryRef properties = CGImageSourceCopyProperties(imageSource, NULL);
        // Mono / 나머지 Stereo
        size_t primaryImageIndex = CGImageSourceGetPrimaryImageIndex(imageSource);
        CFRelease(properties);
    }
    
    struct REEngine *engine = REEngineGetShared();
    struct REServiceLocator *serviceLocator = REEngineGetServiceLocator(engine);
    struct REAssetManager *assetManager = REServiceLocatorGetAssetManager(serviceLocator);
    
    void (^block)(struct REAsset *stereoAsset) = ^(struct REAsset *stereoAsset){
        unsigned int count[1] = {0};
        
        NSError * _Nullable error = nil;
        struct RETextureImportOperation *operation = RETextureImportOperationCreateFromImageSourceArray(@[(id)imageSource], count, MRUIDefaultServiceLocator(), MTLTextureType2DArray, &error);
        assert(operation != NULL);
        
        RETextureImportOperationSetSemantic(operation, 3);
        RETextureImportOperationSetMipmapMode(operation, 0);
        RETextureImportOperationSetCompressionType(operation, 0);
        RETextureImportOperationSetReduceMemoryPeak(operation, NO);
        
        BOOL result = RETextureImportOperationRun(operation, &error);
        assert(result);
        
        struct REAsset *asset = RETextureImportOperationCreateAsset(operation, NO, &error);
        assert(asset != NULL);
        REAssetSetNetworkSharingMode(asset, YES);
        
        struct REAssetLoadRequest *request = REAssetManagerCreateAssetRequest(assetManager);
        result = REAssetLoadRequestSetLoadAndWaitForResourceSharingClients(request, YES, YES, &error);
        assert(result);
        REAssetLoadRequestSetCompletionHandler(request, ^(BOOL success){
            assert(success);
            
            struct REComponent *imagePresentationComponent = REEntityGetOrAddComponentByClass(customEntity, REImagePresentationComponentGetComponentType());
            REImagePresentationComponentSetScreenHeight(imagePresentationComponent, 1.f);
            REImagePresentationComponentSetImageContentType(imagePresentationComponent, 2);
            REImagePresentationComponentSetContentDimensionHint(imagePresentationComponent, 0.f);
            REImagePresentationComponentSetLoadingImageTextureAsset(imagePresentationComponent, NULL);
            REImagePresentationComponentSetMonoImageOrientation(imagePresentationComponent, kCGImagePropertyOrientationUp);
            REImagePresentationComponentSetStereoBaseline(imagePresentationComponent, 19.272f);
            REImagePresentationComponentSetDisparityAdjustment(imagePresentationComponent, 0.024f);
            REImagePresentationComponentSetHorizontalFOV(imagePresentationComponent, 68.5f);
            REImagePresentationComponentSetStereoImageOrientation(imagePresentationComponent, kCGImagePropertyOrientationUp);
            REImagePresentationComponentSetShouldLockMeshToImageAspectRatio(imagePresentationComponent, YES);
            REImagePresentationComponentSetCornerRadiusInPoints(imagePresentationComponent, 46.f);
            REImagePresentationComponentSetSpatial3DCollapseStrength(imagePresentationComponent, 0.f);
            REImagePresentationComponentSetEnableSpecularAndFresnelEffects(imagePresentationComponent, YES);
            REImagePresentationComponentSetDesiredViewingMode(imagePresentationComponent, 0.f);
            REImagePresentationComponentSetDesiredImmersiveViewingMode(imagePresentationComponent, 0.f);
            
            struct REComponent *imagePresentationStatusComponent = REEntityGetOrAddComponentByClass(customEntity, REImagePresentationStatusComponentGetComponentType());
            
            struct REComponent *spatialMediaComponent = REEntityGetOrAddComponentByClass(customEntity, RESpatialMediaComponentGetComponentType());
            struct REComponent *spatialMediaStatusComponent = REEntityGetOrAddComponentByClass(customEntity, RESpatialMediaStatusComponentGetComponentType());
            
            struct REComponent *networkComponent = REEntityGetOrAddComponentByClass(customEntity, RENetworkComponentGetComponentType());
            
            REImagePresentationComponentSetSpatial3DImage(imagePresentationComponent, NULL);
            REImagePresentationComponentSetHasGeneratedSpatial3DImageContent(imagePresentationComponent, NO);
            REImagePresentationComponentSetMonoImageTextureAsset(imagePresentationComponent, asset);
            REImagePresentationComponentSetStereoImageTextureAsset(imagePresentationComponent, stereoAsset);
            
            RENetworkMarkComponentDirty(imagePresentationComponent);
            RENetworkMarkComponentDirty(imagePresentationStatusComponent);
            RENetworkMarkComponentDirty(spatialMediaStatusComponent);
            RENetworkMarkComponentDirty(spatialMediaComponent);
            REImagePresentationStatusComponentPublishUpdatesInApp(imagePresentationStatusComponent);
            RESpatialMediaStatusComponentPublishUpdatesInApp(spatialMediaStatusComponent);
            
            assert(REImagePresentationComponentGetMonoImageTextureAsset(imagePresentationComponent) != NULL);
            assert(REImagePresentationComponentGetStereoImageTextureAsset(imagePresentationComponent) != NULL);
        });
        REAssetLoadRequestAddAsset(request, asset);
    };
    
    {
        unsigned int count[2] = {2, 1};
        
        NSError * _Nullable error = nil;
        struct RETextureImportOperation *operation = RETextureImportOperationCreateFromImageSourceArray(@[(id)imageSource, (id)imageSource], count, MRUIDefaultServiceLocator(), MTLTextureType2DArray, &error);
        assert(operation != NULL);
        
        RETextureImportOperationSetSemantic(operation, 3);
        RETextureImportOperationSetMipmapMode(operation, 0);
        RETextureImportOperationSetCompressionType(operation, 0);
        RETextureImportOperationSetReduceMemoryPeak(operation, NO);
        
        BOOL result = RETextureImportOperationRun(operation, &error);
        assert(result);
        
        struct REAsset *asset = RETextureImportOperationCreateAsset(operation, NO, &error);
        assert(asset != NULL);
        REAssetSetNetworkSharingMode(asset, YES);
        
        struct REAssetLoadRequest *request = REAssetManagerCreateAssetRequest(assetManager);
        result = REAssetLoadRequestSetLoadAndWaitForResourceSharingClients(request, YES, YES, &error);
        assert(result);
        REAssetLoadRequestSetCompletionHandler(request, ^(BOOL success){
            assert(success);
            block(asset);
        });
        REAssetLoadRequestAddAsset(request, asset);
    }
    
//    CFRelease(imageSource);
}

@end
