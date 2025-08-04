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
#import "MyRE-Swift.h"
#import <MXI/MXI.h>
#include <TargetConditionals.h>

@implementation ImagePresentationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view _requestSeparatedState:1 withReason:@"_UIViewSeparatedStateRequestReasonUnspecified"];
    
    struct REEntity *entity = [self.view _reEntity];
    struct REEntity *customEntity = REEntityCreate();
    REEntitySetParent(customEntity, entity);
    
    struct REComponent *transformComponent = REEntityGetOrAddComponentByClass(customEntity, RETransformComponentGetComponentType());
    RETransformComponentSetWorldPosition(transformComponent, simd_make_float3(0.f, 0.f, 0.1f));
    RETransformComponentSetLocalScale(transformComponent, simd_make_float3(0.5f, 0.5f, 0.5f));
    
    struct REComponent *imagePresentationComponent = REEntityGetOrAddComponentByClass(customEntity, REImagePresentationComponentGetComponentType());
    REImagePresentationComponentSetScreenHeight(imagePresentationComponent, 1.f);
    REImagePresentationComponentSetImageContentType(imagePresentationComponent, 2);
    REImagePresentationComponentSetContentDimensionHint(imagePresentationComponent, 0.f);
    REImagePresentationComponentSetLoadingImageTextureAsset(imagePresentationComponent, NULL);
    REImagePresentationComponentSetStereoBaseline(imagePresentationComponent, 19.272f);
    REImagePresentationComponentSetDisparityAdjustment(imagePresentationComponent, 0.024f);
    REImagePresentationComponentSetHorizontalFOV(imagePresentationComponent, 68.5013f);
    REImagePresentationComponentSetShouldLockMeshToImageAspectRatio(imagePresentationComponent, YES);
    REImagePresentationComponentSetCornerRadiusInPoints(imagePresentationComponent, 46.f);
    REImagePresentationComponentSetSpatial3DCollapseStrength(imagePresentationComponent, 0.f);
    REImagePresentationComponentSetEnableSpecularAndFresnelEffects(imagePresentationComponent, YES);
    /*
     mono
     spatialStereo
     spatial3D
     */
    REImagePresentationComponentSetDesiredViewingMode(imagePresentationComponent, 2);
    /*
     Mono
     Portal
     Immersive
     */
    REImagePresentationComponentSetDesiredImmersiveViewingMode(imagePresentationComponent, 1);
    
    struct REComponent *imagePresentationStatusComponent = REEntityGetOrAddComponentByClass(customEntity, REImagePresentationStatusComponentGetComponentType());
    
    struct REComponent *spatialMediaComponent = REEntityGetOrAddComponentByClass(customEntity, RESpatialMediaComponentGetComponentType());
    struct REComponent *spatialMediaStatusComponent = REEntityGetOrAddComponentByClass(customEntity, RESpatialMediaStatusComponentGetComponentType());
    
    struct REComponent *networkComponent = REEntityGetOrAddComponentByClass(customEntity, RENetworkComponentGetComponentType());
    
    REImagePresentationComponentSetSpatial3DImage(imagePresentationComponent, NULL);
    REImagePresentationComponentSetHasGeneratedSpatial3DImageContent(imagePresentationComponent, NO);
    
//    NSURL *url = [NSBundle.mainBundle URLForResource:@"spatial_image_1" withExtension:UTTypeHEIC.preferredFilenameExtension];
    NSURL *url = [NSBundle.mainBundle URLForResource:@"image_1" withExtension:UTTypeJPEG.preferredFilenameExtension];
    assert(url != nil);
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)url, NULL);
    size_t count = CGImageSourceGetCount(imageSource);
    if (count > 0) {
        NSDictionary *properties = (id)CGImageSourceCopyProperties(imageSource, NULL);
        NSArray<NSDictionary *> *groups = [properties objectForKey:(id)kCGImagePropertyGroups];
        
        NSDictionary *stereoPairGroup = nil;
        for (NSDictionary *group in groups) {
            NSString *groupType = [group objectForKey:(id)kCGImagePropertyGroupType];
            if ([groupType isEqual:(id)kCGImagePropertyGroupTypeStereoPair]) {
                stereoPairGroup = group;
                break;
            }
        }
        
        if (stereoPairGroup == nil) {
            unsigned int primaryImageIndex = (unsigned int)CGImageSourceGetPrimaryImageIndex(imageSource);
            struct REAsset *monoAsset = [self newMonoTextureAssetWithImageSource:imageSource index:primaryImageIndex];
            REImagePresentationComponentSetMonoImageTextureAsset(imagePresentationComponent, monoAsset);
            RERelease(monoAsset);
            
            //
            
#if !TARGET_OS_SIMULATOR
            REImagePresentationComponentSetHasGeneratedSpatial3DImageContent(imagePresentationComponent, YES);
            
            CGImageRef cgImage = CGImageSourceCreateImageAtIndex(imageSource, primaryImageIndex, (CFDictionaryRef)@{
                (id)kCGImageSourceDecodeRequest: (id)kCGImageSourceDecodeToSDR,
                @"kCGImageSourceShouldUseRawDataForFullSize": @YES
            });
            CIImage *ciImage = [[CIImage alloc] initWithCGImage:cgImage];
            mxiSceneFromCIImage(ciImage, ^(MXIScene * _Nonnull scene) {
                REImagePresentationComponentSetMXITextureAsset(imagePresentationComponent, NULL);
                
                {
                    struct RETextureAssetData *colorTextureAssetData = RETextureAssetDataCreateWithTexture(scene.colorTexture, (CFDictionaryRef)@{
                        (id)kRETextureAssetCreateOptionSemantic: (id)kRETextureAssetCreateSemanticColor
                    });
                    struct REAsset *colorTexture = REAssetManagerCreateTextureAssetFromData(MRUIDefaultAssetManager(), NULL, colorTextureAssetData);
                    RERelease(colorTextureAssetData);
                    REImagePresentationComponentSetMXIBackgroundTextureAsset(imagePresentationComponent, colorTexture);
                    RERelease(colorTexture);
                }
                
                {
                    NSArray<id<MTLTexture>> *colorTextures = scene.colorTextures;
                    CFMutableArrayRef textures = CFArrayCreateMutable(kCFAllocatorDefault, colorTextures.count, NULL);
                    for (id<MTLTexture> texture in colorTextures) {
                        struct RETextureAssetData *data = RETextureAssetDataCreateWithTexture(texture, (CFDictionaryRef)@{
                            (id)kRETextureAssetCreateOptionSemantic: (id)kRETextureAssetCreateSemanticColor
                        });
                        struct REAsset *colorTexture = REAssetManagerCreateTextureAssetFromData(MRUIDefaultAssetManager(), NULL, data);
                        CFArrayAppendValue(textures, colorTexture);
                        RERelease(data);
                    }
                    
                    REImagePresentationComponentSetMXITextureAssets(imagePresentationComponent, textures);
                    CFRelease(textures);
                }
                
                REImagePresentationComponentSetMXIVerticalFOV(imagePresentationComponent, scene.verticalFOV);
                REImagePresentationComponentSetMXIAspectRatio(imagePresentationComponent, scene.aspectRatio);
                REImagePresentationComponentSetMXILayerCount(imagePresentationComponent, scene.numLayers);
                REImagePresentationComponentSetMXIResolutionWidth(imagePresentationComponent, scene.resolutionWidth);
                REImagePresentationComponentSetMXIResolutionHeight(imagePresentationComponent, scene.resolutionHeight);
                REImagePresentationComponentSetMXINearDistance(imagePresentationComponent, scene.depthRange.near);
                REImagePresentationComponentSetMXIFarDistance(imagePresentationComponent, scene.depthRange.far);
                REImagePresentationComponentSetMXIPremultipliedAlpha(imagePresentationComponent, scene.isPremultipliedAlpha);
                
                NSLog(@"Done!");
            });
#endif
            
            //
            
            CFRelease(imageSource);
            return;
        }
        
        unsigned int monoscopicImageIndex = ((NSNumber *)[stereoPairGroup objectForKey:(id)kCGImagePropertyGroupImageIndexMonoscopic]).unsignedIntValue;
        unsigned int leftImageIndex = ((NSNumber *)[stereoPairGroup objectForKey:(id)kCGImagePropertyGroupImageIndexLeft]).unsignedIntValue;
        unsigned int rightImageIndex = ((NSNumber *)[stereoPairGroup objectForKey:(id)kCGImagePropertyGroupImageIndexRight]).unsignedIntValue;
        
        NSDictionary *fileContents = [properties objectForKey:(id)kCGImagePropertyFileContentsDictionary];
        NSNumber *imageCount = [fileContents objectForKey:(id)kCGImagePropertyImageCount];
        assert(imageCount.unsignedIntValue == 3);
        NSArray<NSDictionary *> *images = [fileContents objectForKey:(id)kCGImagePropertyImages];
        
        NSDictionary *primaryImage = nil;
        NSDictionary *leftImage = nil;
        NSDictionary *rightImage = nil;
        for (NSDictionary *image in images) {
            NSNumber *imageIndex = [image objectForKey:(id)kCGImagePropertyImageIndex];
            assert(imageIndex != nil);
            if (imageIndex.unsignedIntValue == monoscopicImageIndex) {
                primaryImage = image;
            } else if (imageIndex.unsignedIntValue == leftImageIndex) {
                leftImage = image;
            } else if (imageIndex.unsignedIntValue == rightImageIndex) {
                rightImage = image;
            }
        }
        
        CGImagePropertyOrientation monoOrientation = ((NSNumber *)[primaryImage objectForKey:(id)kCGImagePropertyOrientation]).unsignedIntValue;
        CGImagePropertyOrientation stereoOrientation = ((NSNumber *)[leftImage objectForKey:(id)kCGImagePropertyOrientation]).unsignedIntValue;
        assert(stereoOrientation == ((NSNumber *)[rightImage objectForKey:(id)kCGImagePropertyOrientation]).unsignedIntValue);
        
        [properties release];
        
        REImagePresentationComponentSetMonoImageOrientation(imagePresentationComponent, monoOrientation);
        REImagePresentationComponentSetStereoImageOrientation(imagePresentationComponent, stereoOrientation);
        
        struct REAsset *monoAsset = [self newMonoTextureAssetWithImageSource:imageSource index:monoscopicImageIndex];
        REImagePresentationComponentSetMonoImageTextureAsset(imagePresentationComponent, monoAsset);
        RERelease(monoAsset);
        
        struct REAsset *stereoAsset = [self newStereoTextureAssetWithImageSource:imageSource leftIndex:leftImageIndex rightIndex:rightImageIndex];
        REImagePresentationComponentSetStereoImageTextureAsset(imagePresentationComponent, stereoAsset);
        REImagePresentationComponentSetHasGeneratedSpatial3DImageContent(imagePresentationComponent, NO);
        RERelease(stereoAsset);
        
        RENetworkMarkComponentDirty(imagePresentationComponent);
    } else {
        abort();
    }
    
    RERelease(customEntity);
    CFRelease(imageSource);
}

- (struct REAsset *)newMonoTextureAssetWithImageSource:(CGImageSourceRef)imageSource index:(unsigned int)index {
    unsigned int indexes[1] = {index};
    
    NSError * _Nullable error = nil;
    struct RETextureImportOperation *operation = RETextureImportOperationCreateFromImageSourceArray(@[(id)imageSource], indexes, MRUIDefaultServiceLocator(), MTLTextureType2DArray, &error);
    assert(operation != NULL);
    
    RETextureImportOperationSetSemantic(operation, 3);
    RETextureImportOperationSetMipmapMode(operation, 0);
    RETextureImportOperationSetCompressionType(operation, 0);
    RETextureImportOperationSetReduceMemoryPeak(operation, NO);
    
    BOOL result = RETextureImportOperationRun(operation, &error);
    assert(result);
    
    struct REAsset *asset = RETextureImportOperationCreateAsset(operation, NO, &error);
    assert(asset != NULL);
    RERelease(operation);
    
    REAssetSetNetworkSharingMode(asset, YES);
    
    struct REAssetLoadRequest *request = REAssetManagerCreateAssetRequest(MRUIDefaultAssetManager());
    result = REAssetLoadRequestSetLoadAndWaitForResourceSharingClients(request, YES, YES, &error);
    assert(result);
    
    REAssetLoadRequestAddAsset(request, asset);
    REAssetLoadRequestWaitForCompletion(request);
    error = [REAssetLoadRequestCopyError(request) autorelease];
    assert(error == nil);
    RERelease(request);
    return asset;
}

- (struct REAsset *)newStereoTextureAssetWithImageSource:(CGImageSourceRef)imageSource leftIndex:(unsigned int)leftIndex rightIndex:(unsigned int)rightIndex {
    unsigned int indexes[2] = {leftIndex, rightIndex};
    
    NSError * _Nullable error = nil;
    struct RETextureImportOperation *operation = RETextureImportOperationCreateFromImageSourceArray(@[(id)imageSource, (id)imageSource], indexes, MRUIDefaultServiceLocator(), MTLTextureType2DArray, &error);
    assert(operation != NULL);
    
    RETextureImportOperationSetSemantic(operation, 3);
    RETextureImportOperationSetMipmapMode(operation, 0);
    RETextureImportOperationSetCompressionType(operation, 0);
    RETextureImportOperationSetReduceMemoryPeak(operation, NO);
    
    BOOL result = RETextureImportOperationRun(operation, &error);
    assert(result);
    
    struct REAsset *asset = RETextureImportOperationCreateAsset(operation, NO, &error);
    assert(asset != NULL);
    RERelease(operation);
    
    REAssetSetNetworkSharingMode(asset, YES);
    
    struct REAssetLoadRequest *request = REAssetManagerCreateAssetRequest(MRUIDefaultAssetManager());
    result = REAssetLoadRequestSetLoadAndWaitForResourceSharingClients(request, YES, YES, &error);
    assert(result);
    
    REAssetLoadRequestAddAsset(request, asset);
    REAssetLoadRequestWaitForCompletion(request);
    error = [REAssetLoadRequestCopyError(request) autorelease];
    assert(error == nil);
    RERelease(request);
    return asset;
}

@end

/*
 _triangleIndices
 _triangleSliceIndices
 _vertexPositions
 _vertexUVs
 
 static RealityFoundation.MXISceneResource.createLowLevelMesh(mxiScene: __C.MXIScene) throws -> RealityFoundation.LowLevelMesh
 
 REAssetManagerCreateMeshAssetWithDirectMesh
 */

/*
 bt 1
* thread #10, name = 'Task 1', stop reason = breakpoint 4.110
    frame #0: 0x00000001d5854774 CoreRE`REMeshAttributesDescriptorCreate
 bt 1
* thread #10, name = 'Task 1', stop reason = breakpoint 4.91
    frame #0: 0x00000001d5854a40 CoreRE`REMeshAttributeDescriptorArraySetCustomName
 bt 1
* thread #10, name = 'Task 1', stop reason = breakpoint 4.163
    frame #0: 0x00000001d585515c CoreRE`REMeshDefinitionCreateWithAttributes
 bt 1
* thread #10, name = 'Task 1', stop reason = breakpoint 4.162
    frame #0: 0x00000001d5855164 CoreRE`REMeshDefinitionCreateInstancedWithAttributes
 bt 1
* thread #10, name = 'Task 1', stop reason = breakpoint 4.168
    frame #0: 0x00000001d58552c0 CoreRE`REMeshDefinitionSetIndicesWithData
 bt 1
* thread #10, name = 'Task 1', stop reason = breakpoint 4.164
    frame #0: 0x00000001d58555e0 CoreRE`REMeshDefinitionSetAttributeWithData
 bt 1
* thread #10, name = 'Task 1', stop reason = breakpoint 4.166
    frame #0: 0x00000001d585563c CoreRE`REMeshDefinitionSetCustomAttributeWithData
 bt 1
* thread #10, name = 'Task 1', stop reason = breakpoint 4.110
    frame #0: 0x00000001d5854774 CoreRE`REMeshAttributesDescriptorCreate
 bt 1
* thread #10, name = 'Task 1', stop reason = breakpoint 4.91
    frame #0: 0x00000001d5854a40 CoreRE`REMeshAttributeDescriptorArraySetCustomName
 bt 1
* thread #10, name = 'Task 1', stop reason = breakpoint 4.163
    frame #0: 0x00000001d585515c CoreRE`REMeshDefinitionCreateWithAttributes
 bt 1
* thread #10, name = 'Task 1', stop reason = breakpoint 4.162
    frame #0: 0x00000001d5855164 CoreRE`REMeshDefinitionCreateInstancedWithAttributes
 bt 1
* thread #10, name = 'Task 1', stop reason = breakpoint 4.168
    frame #0: 0x00000001d58552c0 CoreRE`REMeshDefinitionSetIndicesWithData
 bt 1
* thread #10, name = 'Task 1', stop reason = breakpoint 4.164
    frame #0: 0x00000001d58555e0 CoreRE`REMeshDefinitionSetAttributeWithData
 bt 1
* thread #10, name = 'Task 1', stop reason = breakpoint 4.166
    frame #0: 0x00000001d585563c CoreRE`REMeshDefinitionSetCustomAttributeWithData
 bt 1
* thread #10, name = 'Task 1', stop reason = breakpoint 4.110
    frame #0: 0x00000001d5854774 CoreRE`REMeshAttributesDescriptorCreate
 bt 1
* thread #10, name = 'Task 1', stop reason = breakpoint 4.91
    frame #0: 0x00000001d5854a40 CoreRE`REMeshAttributeDescriptorArraySetCustomName
 bt 1
* thread #10, name = 'Task 1', stop reason = breakpoint 4.163
    frame #0: 0x00000001d585515c CoreRE`REMeshDefinitionCreateWithAttributes
 bt 1
* thread #10, name = 'Task 1', stop reason = breakpoint 4.162
    frame #0: 0x00000001d5855164 CoreRE`REMeshDefinitionCreateInstancedWithAttributes
 bt 1
* thread #10, name = 'Task 1', stop reason = breakpoint 4.168
    frame #0: 0x00000001d58552c0 CoreRE`REMeshDefinitionSetIndicesWithData
 bt 1
* thread #10, name = 'Task 1', stop reason = breakpoint 4.164
    frame #0: 0x00000001d58555e0 CoreRE`REMeshDefinitionSetAttributeWithData
 bt 1
* thread #10, name = 'Task 1', stop reason = breakpoint 4.166
    frame #0: 0x00000001d585563c CoreRE`REMeshDefinitionSetCustomAttributeWithData
 bt 1
* thread #10, name = 'Task 1', stop reason = breakpoint 4.134
    frame #0: 0x00000001d58f1ff4 CoreRE`REMeshComponentGetComponentType
 bt 1
* thread #10, name = 'Task 1', stop reason = breakpoint 4.134
    frame #0: 0x00000001d58f1ff4 CoreRE`REMeshComponentGetComponentType
 bt 1
* thread #10, name = 'Task 1', stop reason = breakpoint 4.134
    frame #0: 0x00000001d58f1ff4 CoreRE`REMeshComponentGetComponentType
 
 bt 1
* thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 2.5
    frame #0: 0x00000001d58da444 CoreRE`REImagePresentationComponentSetMXIMeshAsset
 bt 1✅
* thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 2.10
    frame #0: 0x00000001d58da1c0 CoreRE`REImagePresentationComponentSetMXITextureAsset
 bt 1 ✅
* thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 2.11
    frame #0: 0x00000001d58da2e4 CoreRE`REImagePresentationComponentSetMXITextureAssets
 bt 1✅
* thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 2.2
    frame #0: 0x00000001d58da3bc CoreRE`REImagePresentationComponentSetMXIBackgroundTextureAsset
 bt 1 ✅
* thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 2.12
    frame #0: 0x00000001d58da510 CoreRE`REImagePresentationComponentSetMXIVerticalFOV
 bt 1 ✅
* thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 2.1
    frame #0: 0x00000001d58da558 CoreRE`REImagePresentationComponentSetMXIAspectRatio
 bt 1 ✅
* thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 2.6
    frame #0: 0x00000001d58da584 CoreRE`REImagePresentationComponentSetMXINearDistance
 bt 1 ✅
* thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 2.3
    frame #0: 0x00000001d58da5cc CoreRE`REImagePresentationComponentSetMXIFarDistance
 bt 1 ✅
* thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 2.4
    frame #0: 0x00000001d58da614 CoreRE`REImagePresentationComponentSetMXILayerCount
 bt 1 ✅
* thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 2.9
    frame #0: 0x00000001d58da65c CoreRE`REImagePresentationComponentSetMXIResolutionWidth
 bt 1 ✅
* thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 2.8
    frame #0: 0x00000001d58da6a4 CoreRE`REImagePresentationComponentSetMXIResolutionHeight
 bt 1 ✅
* thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 2.7
    frame #0: 0x00000001d58da6ec CoreRE`REImagePresentationComponentSetMXIPremultipliedAlpha
 */
