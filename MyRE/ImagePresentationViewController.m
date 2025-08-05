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
#import <DirectResource/DirectResource.h>

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
            
            CGImageRef cgImage = CGImageSourceCreateImageAtIndex(imageSource, primaryImageIndex, (CFDictionaryRef)@{
                (id)kCGImageSourceDecodeRequest: (id)kCGImageSourceDecodeToSDR,
                @"kCGImageSourceShouldUseRawDataForFullSize": @YES
            });
            CIImage *ciImage = [[CIImage alloc] initWithCGImage:cgImage];
            mxiSceneFromCIImage(ciImage, ^(MXIScene * _Nonnull scene) {
                [scene retain];
                
                dispatch_async(dispatch_get_main_queue(), ^{
//                    REImagePresentationComponentSetMXITextureAsset(imagePresentationComponent, NULL);
                    
//                    {
//                        assert(scene.colorTexture != nil);
//                        struct RETextureAssetData *colorTextureAssetData = RETextureAssetDataCreateWithTexture(scene.colorTextures[0], (CFDictionaryRef)@{
//                            (id)kRETextureAssetCreateOptionSemantic: (id)kRETextureAssetCreateSemanticColor
//                        });
//                        struct REAsset *colorTexture = REAssetManagerCreateTextureAssetFromData(MRUIDefaultAssetManager(), NULL, colorTextureAssetData);
//                        RERelease(colorTextureAssetData);
//                        REImagePresentationComponentSetMXIBackgroundTextureAsset(imagePresentationComponent, colorTexture);
//                        RERelease(colorTexture);
//                    }
                    
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
                    
                    {
                        struct DRMeshDescriptor *descriptor = DRMeshDescriptorCreate();
                        DRMeshDescriptorSetIndexCapacity(descriptor, scene.triangleCount * 3);
                        DRMeshDescriptorSetIndexType(descriptor, scene.type);
                        DRMeshDescriptorSetVertexCapacity(descriptor, scene.vertexCount);
                        DRMeshDescriptorSetVertexBufferCount(descriptor, 3);
                        DRMeshDescriptorSetVertexAttributeCount(descriptor, 3);
                        DRMeshDescriptorSetVertexLayoutCount(descriptor, 3);
                        DRMeshDescriptorSetVertexAttributeFormat(descriptor, 0, 0, MTLVertexFormatFloat3, 0, 0);
                        DRMeshDescriptorSetVertexAttributeFormat(descriptor, 1, 5, MTLVertexFormatFloat2, 1, 0);
                        DRMeshDescriptorSetVertexAttributeFormat(descriptor, 2, 6, MTLVertexFormatFloat3, 2, 0);
                        DRMeshDescriptorSetVertexLayout(descriptor, 0, 0, 0, 12);
                        DRMeshDescriptorSetVertexLayout(descriptor, 1, 1, 0, 8);
                        DRMeshDescriptorSetVertexLayout(descriptor, 2, 2, 0, 8);
                        
                        struct DRContext *drContext = REServiceLocatorGetDirectResourceService(MRUIDefaultServiceLocator());
                        NSError * _Nullable error = nil;
                        struct DRMesh *drMesh = DRContextCreateMesh(drContext, descriptor, &error);
                        assert(drMesh != NULL);
                        DRRelease(descriptor);
                        DRMeshSetPartCount(drMesh, 1);
                        DRMeshSetPartAt(drMesh, 0, 0, 0xd5fc, 0x3, 0);
                        
                        NSLog(@"%lld", [scene vertexCount]); // 40192
                        NSLog(@"%lld", [scene triangleCount]); // 18292
                        
                        NSLog(@"%lld", [scene.vertexPositions length]); // 643072
                        NSLog(@"%lld", [scene.vertexUVs length]); // 321536
                        NSLog(@"%lld", [scene.triangleIndices length]); // 219504
                        NSLog(@"%lld", [scene.triangleSliceIndices length]); // 73168
                        
                        // TODO
                        // length = 482304
                        DRMeshUpdateVertices(drMesh, 0, ^(void * _Nonnull bytes, long long length) {
                            const uint8_t *src = (const uint8_t *)(scene.vertexPositions.contents);
                            float *dst = (float *)bytes;
                            
                            for (NSUInteger i = 0; i < scene.vertexCount; i++) {
                                const float *position = (const float *)(src + i * 16);
                                dst[i * 3 + 0] = position[0];
                                dst[i * 3 + 1] = position[1];
                                dst[i * 3 + 2] = position[2];
                            }
                        });
                        
                        // length = 321536
                        DRMeshUpdateVertices(drMesh, 1, ^(void * _Nonnull bytes, long long length) {
                            memcpy(bytes, scene.vertexUVs.contents, length);
                        });
                        
                        // length = 321536
                        DRMeshUpdateVertices(drMesh, 2, ^(void * _Nonnull bytes, long long length) {
                            memcpy(bytes, scene.vertexUVs.contents, length);
                        });
                        
                        // length = 114688
                        DRMeshUpdateIndices(drMesh, ^(void * _Nonnull bytes, long long length) {
                            const uint32_t *src = scene.triangleIndices.contents;
                            uint16_t *dst = (uint16_t *)bytes;
                            
                            for (NSUInteger i = 0; i < scene.triangleCount * 3; i++) {
                                uint32_t index = src[i];
                                assert(index <= UINT16_MAX); 
                                dst[i] = (uint16_t)index;
                            }
                        });
                        
                        struct REAsset *meshAsset = REAssetManagerCreateMeshAssetWithDirectMesh(MRUIDefaultAssetManager(), drMesh);
                        DRRelease(drMesh);
                        REImagePresentationComponentSetMXIMeshAsset(imagePresentationComponent, meshAsset);
                        RERelease(meshAsset);
                    }
                    
                    REImagePresentationComponentSetMXIVerticalFOV(imagePresentationComponent, scene.verticalFOV);
                    REImagePresentationComponentSetMXIAspectRatio(imagePresentationComponent, scene.aspectRatio);
                    REImagePresentationComponentSetMXILayerCount(imagePresentationComponent, scene.numLayers);
                    REImagePresentationComponentSetMXIResolutionWidth(imagePresentationComponent, scene.resolutionWidth);
                    REImagePresentationComponentSetMXIResolutionHeight(imagePresentationComponent, scene.resolutionHeight);
                    REImagePresentationComponentSetMXINearDistance(imagePresentationComponent, scene.depthRange.near);
                    REImagePresentationComponentSetMXIFarDistance(imagePresentationComponent, scene.depthRange.far);
                    REImagePresentationComponentSetMXIPremultipliedAlpha(imagePresentationComponent, scene.isPremultipliedAlpha);
                    REImagePresentationComponentSetHasGeneratedSpatial3DImageContent(imagePresentationComponent, YES);
                    
                    RENetworkMarkComponentDirty(imagePresentationComponent);
                    NSLog(@"Done!");
                });
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
 
 (lldb) c
 Process 3747 resuming
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.49
     frame #0: 0x00000001d90e9d20 DirectResource`DRContextHasOpenCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.31
     frame #0: 0x00000001d90e9d74 DirectResource`DRContextCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.49
     frame #0: 0x00000001d90e9d20 DirectResource`DRContextHasOpenCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.31
     frame #0: 0x00000001d90e9d74 DirectResource`DRContextCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.49
     frame #0: 0x00000001d90e9d20 DirectResource`DRContextHasOpenCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.31
     frame #0: 0x00000001d90e9d74 DirectResource`DRContextCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.49
     frame #0: 0x00000001d90e9d20 DirectResource`DRContextHasOpenCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.31
     frame #0: 0x00000001d90e9d74 DirectResource`DRContextCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.49
     frame #0: 0x00000001d90e9d20 DirectResource`DRContextHasOpenCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.31
     frame #0: 0x00000001d90e9d74 DirectResource`DRContextCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.49
     frame #0: 0x00000001d90e9d20 DirectResource`DRContextHasOpenCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.31
     frame #0: 0x00000001d90e9d74 DirectResource`DRContextCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.49
     frame #0: 0x00000001d90e9d20 DirectResource`DRContextHasOpenCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.31
     frame #0: 0x00000001d90e9d74 DirectResource`DRContextCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.49
     frame #0: 0x00000001d90e9d20 DirectResource`DRContextHasOpenCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.31
     frame #0: 0x00000001d90e9d74 DirectResource`DRContextCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.49
     frame #0: 0x00000001d90e9d20 DirectResource`DRContextHasOpenCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.31
     frame #0: 0x00000001d90e9d74 DirectResource`DRContextCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.49
     frame #0: 0x00000001d90e9d20 DirectResource`DRContextHasOpenCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.31
     frame #0: 0x00000001d90e9d74 DirectResource`DRContextCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.49
     frame #0: 0x00000001d90e9d20 DirectResource`DRContextHasOpenCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.31
     frame #0: 0x00000001d90e9d74 DirectResource`DRContextCommit
 IOSurface creation failed: e00002c2 parentID: 00000000 properties: {
     IOSurfaceAddress = 4570857472;
     IOSurfaceAllocSize = 9366783;
     IOSurfaceCacheMode = 0;
     IOSurfaceMapCacheAttribute = 1;
     IOSurfaceName = CMPhoto;
     IOSurfacePixelFormat = 1246774599;
 }
 IOSurface creation failed: e00002c2 parentID: 00000000 property: IOSurfaceCacheMode
 IOSurface creation failed: e00002c2 parentID: 00000000 property: IOSurfacePixelFormat
 IOSurface creation failed: e00002c2 parentID: 00000000 property: IOSurfaceMapCacheAttribute
 IOSurface creation failed: e00002c2 parentID: 00000000 property: IOSurfaceAddress
 IOSurface creation failed: e00002c2 parentID: 00000000 property: IOSurfaceAllocSize
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.49
     frame #0: 0x00000001d90e9d20 DirectResource`DRContextHasOpenCommit
 IOSurface creation failed: e00002c2 parentID: 00000000 property: IOSurfaceName
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.31
     frame #0: 0x00000001d90e9d74 DirectResource`DRContextCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.49
     frame #0: 0x00000001d90e9d20 DirectResource`DRContextHasOpenCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.31
     frame #0: 0x00000001d90e9d74 DirectResource`DRContextCommit
 IOSurface creation failed: e00002c2 parentID: 00000000 properties: {
     IOSurfaceAddress = 4570857472;
     IOSurfaceAllocSize = 9366783;
     IOSurfaceCacheMode = 0;
     IOSurfaceMapCacheAttribute = 1;
     IOSurfaceName = CMPhoto;
     IOSurfacePixelFormat = 1246774599;
 }
 IOSurface creation failed: e00002c2 parentID: 00000000 property: IOSurfaceCacheMode
 IOSurface creation failed: e00002c2 parentID: 00000000 property: IOSurfacePixelFormat
 IOSurface creation failed: e00002c2 parentID: 00000000 property: IOSurfaceMapCacheAttribute
 IOSurface creation failed: e00002c2 parentID: 00000000 property: IOSurfaceAddress
 IOSurface creation failed: e00002c2 parentID: 00000000 property: IOSurfaceAllocSize
 IOSurface creation failed: e00002c2 parentID: 00000000 property: IOSurfaceName
 The return value of deprecated event handler is ignored. Please use EventUpdateCallback instead.
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.71
     frame #0: 0x00000001d90e7e58 DirectResource`DRMeshDescriptorCreate
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.80
     frame #0: 0x00000001d90e7ef0 DirectResource`DRMeshDescriptorSetIndexCapacity
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.81
     frame #0: 0x00000001d90e7f18 DirectResource`DRMeshDescriptorSetIndexType
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.85
     frame #0: 0x00000001d90e7ec8 DirectResource`DRMeshDescriptorSetVertexCapacity
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.84
     frame #0: 0x00000001d90e7ea0 DirectResource`DRMeshDescriptorSetVertexBufferCount
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.82
     frame #0: 0x00000001d90e7f48 DirectResource`DRMeshDescriptorSetVertexAttributeCount
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.87
     frame #0: 0x00000001d90e8174 DirectResource`DRMeshDescriptorSetVertexLayoutCount
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.83
     frame #0: 0x00000001d90e811c DirectResource`DRMeshDescriptorSetVertexAttributeFormat
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.83
     frame #0: 0x00000001d90e811c DirectResource`DRMeshDescriptorSetVertexAttributeFormat
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.83
     frame #0: 0x00000001d90e811c DirectResource`DRMeshDescriptorSetVertexAttributeFormat
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.86
     frame #0: 0x00000001d90e8340 DirectResource`DRMeshDescriptorSetVertexLayout
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.86
     frame #0: 0x00000001d90e8340 DirectResource`DRMeshDescriptorSetVertexLayout
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.86
     frame #0: 0x00000001d90e8340 DirectResource`DRMeshDescriptorSetVertexLayout
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.45
     frame #0: 0x00000001d90e9978 DirectResource`DRContextCreateMesh
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.114
     frame #0: 0x00000001d90ea5e4 DirectResource`DRResourceGetIdentifier
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.113
     frame #0: 0x00000001d90ea600 DirectResource`DRResourceGetClientIdentifier
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.114
     frame #0: 0x00000001d90ea5e4 DirectResource`DRResourceGetIdentifier
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.106
     frame #0: 0x00000001d90e8d10 DirectResource`DRMeshUpdateVertices
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.106
     frame #0: 0x00000001d90e8d10 DirectResource`DRMeshUpdateVertices
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.106
     frame #0: 0x00000001d90e8d10 DirectResource`DRMeshUpdateVertices
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.104
     frame #0: 0x00000001d90e8f30 DirectResource`DRMeshUpdateIndices
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.90
     frame #0: 0x00000001d90e872c DirectResource`DRMeshGetPartCount
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.102
     frame #0: 0x00000001d90e8764 DirectResource`DRMeshSetPartCount
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.114
     frame #0: 0x00000001d90ea5e4 DirectResource`DRResourceGetIdentifier
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.113
     frame #0: 0x00000001d90ea600 DirectResource`DRResourceGetClientIdentifier
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.90
     frame #0: 0x00000001d90e872c DirectResource`DRMeshGetPartCount
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.101
     frame #0: 0x00000001d90e8778 DirectResource`DRMeshSetPartAt
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.114
     frame #0: 0x00000001d90ea5e4 DirectResource`DRResourceGetIdentifier
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.113
     frame #0: 0x00000001d90ea600 DirectResource`DRResourceGetClientIdentifier
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.67
     frame #0: 0x00000001d90ea690 DirectResource`DRMeshAsResource
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.114
     frame #0: 0x00000001d90ea5e4 DirectResource`DRResourceGetIdentifier
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.94
     frame #0: 0x00000001d90e9010 DirectResource`DRMeshReadIndicesUsing
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.96
     frame #0: 0x00000001d90e8fe0 DirectResource`DRMeshReadVerticesUsing
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.96
     frame #0: 0x00000001d90e8fe0 DirectResource`DRMeshReadVerticesUsing
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.96
     frame #0: 0x00000001d90e8fe0 DirectResource`DRMeshReadVerticesUsing
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.96
     frame #0: 0x00000001d90e8fe0 DirectResource`DRMeshReadVerticesUsing
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.68
     frame #0: 0x00000001d90e845c DirectResource`DRMeshCopyDescriptor
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.70
     frame #0: 0x00000001d90e8adc DirectResource`DRMeshDescriptorCalculateBufferSizes
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.68
     frame #0: 0x00000001d90e845c DirectResource`DRMeshCopyDescriptor
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.90
     frame #0: 0x00000001d90e872c DirectResource`DRMeshGetPartCount
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.68
     frame #0: 0x00000001d90e845c DirectResource`DRMeshCopyDescriptor
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.74
     frame #0: 0x00000001d90e7f2c DirectResource`DRMeshDescriptorGetVertexAttributeCount
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.73
     frame #0: 0x00000001d90e7f04 DirectResource`DRMeshDescriptorGetIndexType
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.73
     frame #0: 0x00000001d90e7f04 DirectResource`DRMeshDescriptorGetIndexType
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.74
     frame #0: 0x00000001d90e7f2c DirectResource`DRMeshDescriptorGetVertexAttributeCount
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.75
     frame #0: 0x00000001d90e80d0 DirectResource`DRMeshDescriptorGetVertexAttributeFormat
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.78
     frame #0: 0x00000001d90e82e8 DirectResource`DRMeshDescriptorGetVertexLayout
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.75
     frame #0: 0x00000001d90e80d0 DirectResource`DRMeshDescriptorGetVertexAttributeFormat
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.78
     frame #0: 0x00000001d90e82e8 DirectResource`DRMeshDescriptorGetVertexLayout
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.75
     frame #0: 0x00000001d90e80d0 DirectResource`DRMeshDescriptorGetVertexAttributeFormat
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.78
     frame #0: 0x00000001d90e82e8 DirectResource`DRMeshDescriptorGetVertexLayout
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.90
     frame #0: 0x00000001d90e872c DirectResource`DRMeshGetPartCount
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.89
     frame #0: 0x00000001d90e88a0 DirectResource`DRMeshGetPartAt
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.73
     frame #0: 0x00000001d90e7f04 DirectResource`DRMeshDescriptorGetIndexType
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.90
     frame #0: 0x00000001d90e872c DirectResource`DRMeshGetPartCount
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.89
     frame #0: 0x00000001d90e88a0 DirectResource`DRMeshGetPartAt
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.67
     frame #0: 0x00000001d90ea690 DirectResource`DRMeshAsResource
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.113
     frame #0: 0x00000001d90ea600 DirectResource`DRResourceGetClientIdentifier
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.49
     frame #0: 0x00000001d90e9d20 DirectResource`DRContextHasOpenCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.51
     frame #0: 0x00000001d90e9dc8 DirectResource`DRContextSetCommitUserPayload
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.54
     frame #0: 0x00000001d90e916c DirectResource`DRFenceCreate
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.32
     frame #0: 0x00000001d90e9ecc DirectResource`DRContextCommitAddFence
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.31
     frame #0: 0x00000001d90e9d74 DirectResource`DRContextCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.56
     frame #0: 0x00000001d90e91b0 DirectResource`DRFenceInvalidate
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.117
     frame #0: 0x00000001d90eb770 DirectResource`DRResourcesCommitCopyToXPC
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.49
     frame #0: 0x00000001d90e9d20 DirectResource`DRContextHasOpenCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.31
     frame #0: 0x00000001d90e9d74 DirectResource`DRContextCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.49
     frame #0: 0x00000001d90e9d20 DirectResource`DRContextHasOpenCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.31
     frame #0: 0x00000001d90e9d74 DirectResource`DRContextCommit
 Video texture allocator is not initialized.
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.60
     frame #0: 0x00000001d90eabbc DirectResource`DRMemoryResourceCreate
 [VideoLightSpillGenerator] [VideoLightSpillMPSCallsPrewarm] Failed to create input texture with MTLPixelFormat MTLPixelFormatBGRA8Unorm_sRGB
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.64
     frame #0: 0x00000001d90eacc4 DirectResource`DRMemoryResourceGetBytes
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.65
     frame #0: 0x00000001d90eacb0 DirectResource`DRMemoryResourceGetLength
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.63
     frame #0: 0x00000001d90eacd4 DirectResource`DRMemoryResourceDidUpdateBytes
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.60
     frame #0: 0x00000001d90eabbc DirectResource`DRMemoryResourceCreate
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.64
     frame #0: 0x00000001d90eacc4 DirectResource`DRMemoryResourceGetBytes
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.65
     frame #0: 0x00000001d90eacb0 DirectResource`DRMemoryResourceGetLength
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.63
     frame #0: 0x00000001d90eacd4 DirectResource`DRMemoryResourceDidUpdateBytes
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.66
     frame #0: 0x00000001d90eac9c DirectResource`DRMemoryResourceIsPrivateToProcess
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.65
     frame #0: 0x00000001d90eacb0 DirectResource`DRMemoryResourceGetLength
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.65
     frame #0: 0x00000001d90eacb0 DirectResource`DRMemoryResourceGetLength
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.58
     frame #0: 0x00000001d90eabf0 DirectResource`DRMemoryResourceCopyBuffer
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.58
     frame #0: 0x00000001d90eabf0 DirectResource`DRMemoryResourceCopyBuffer
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.65
     frame #0: 0x00000001d90eacb0 DirectResource`DRMemoryResourceGetLength
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.65
     frame #0: 0x00000001d90eacb0 DirectResource`DRMemoryResourceGetLength
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.60
     frame #0: 0x00000001d90eabbc DirectResource`DRMemoryResourceCreate
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.64
     frame #0: 0x00000001d90eacc4 DirectResource`DRMemoryResourceGetBytes
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.65
     frame #0: 0x00000001d90eacb0 DirectResource`DRMemoryResourceGetLength
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.63
     frame #0: 0x00000001d90eacd4 DirectResource`DRMemoryResourceDidUpdateBytes
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.60
     frame #0: 0x00000001d90eabbc DirectResource`DRMemoryResourceCreate
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.64
     frame #0: 0x00000001d90eacc4 DirectResource`DRMemoryResourceGetBytes
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.65
     frame #0: 0x00000001d90eacb0 DirectResource`DRMemoryResourceGetLength
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.63
     frame #0: 0x00000001d90eacd4 DirectResource`DRMemoryResourceDidUpdateBytes
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.66
     frame #0: 0x00000001d90eac9c DirectResource`DRMemoryResourceIsPrivateToProcess
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.65
     frame #0: 0x00000001d90eacb0 DirectResource`DRMemoryResourceGetLength
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.65
     frame #0: 0x00000001d90eacb0 DirectResource`DRMemoryResourceGetLength
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.58
     frame #0: 0x00000001d90eabf0 DirectResource`DRMemoryResourceCopyBuffer
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.58
     frame #0: 0x00000001d90eabf0 DirectResource`DRMemoryResourceCopyBuffer
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.65
     frame #0: 0x00000001d90eacb0 DirectResource`DRMemoryResourceGetLength
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.65
     frame #0: 0x00000001d90eacb0 DirectResource`DRMemoryResourceGetLength
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.60
     frame #0: 0x00000001d90eabbc DirectResource`DRMemoryResourceCreate
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.64
     frame #0: 0x00000001d90eacc4 DirectResource`DRMemoryResourceGetBytes
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.65
     frame #0: 0x00000001d90eacb0 DirectResource`DRMemoryResourceGetLength
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.63
     frame #0: 0x00000001d90eacd4 DirectResource`DRMemoryResourceDidUpdateBytes
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.60
     frame #0: 0x00000001d90eabbc DirectResource`DRMemoryResourceCreate
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.64
     frame #0: 0x00000001d90eacc4 DirectResource`DRMemoryResourceGetBytes
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.65
     frame #0: 0x00000001d90eacb0 DirectResource`DRMemoryResourceGetLength
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.63
     frame #0: 0x00000001d90eacd4 DirectResource`DRMemoryResourceDidUpdateBytes
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.66
     frame #0: 0x00000001d90eac9c DirectResource`DRMemoryResourceIsPrivateToProcess
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.65
     frame #0: 0x00000001d90eacb0 DirectResource`DRMemoryResourceGetLength
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.65
     frame #0: 0x00000001d90eacb0 DirectResource`DRMemoryResourceGetLength
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.58
     frame #0: 0x00000001d90eabf0 DirectResource`DRMemoryResourceCopyBuffer
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.58
     frame #0: 0x00000001d90eabf0 DirectResource`DRMemoryResourceCopyBuffer
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.65
     frame #0: 0x00000001d90eacb0 DirectResource`DRMemoryResourceGetLength
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.65
     frame #0: 0x00000001d90eacb0 DirectResource`DRMemoryResourceGetLength
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.60
     frame #0: 0x00000001d90eabbc DirectResource`DRMemoryResourceCreate
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.64
     frame #0: 0x00000001d90eacc4 DirectResource`DRMemoryResourceGetBytes
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.65
     frame #0: 0x00000001d90eacb0 DirectResource`DRMemoryResourceGetLength
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.63
     frame #0: 0x00000001d90eacd4 DirectResource`DRMemoryResourceDidUpdateBytes
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.60
     frame #0: 0x00000001d90eabbc DirectResource`DRMemoryResourceCreate
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.64
     frame #0: 0x00000001d90eacc4 DirectResource`DRMemoryResourceGetBytes
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.65
     frame #0: 0x00000001d90eacb0 DirectResource`DRMemoryResourceGetLength
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.63
     frame #0: 0x00000001d90eacd4 DirectResource`DRMemoryResourceDidUpdateBytes
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.66
     frame #0: 0x00000001d90eac9c DirectResource`DRMemoryResourceIsPrivateToProcess
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.65
     frame #0: 0x00000001d90eacb0 DirectResource`DRMemoryResourceGetLength
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.65
     frame #0: 0x00000001d90eacb0 DirectResource`DRMemoryResourceGetLength
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.58
     frame #0: 0x00000001d90eabf0 DirectResource`DRMemoryResourceCopyBuffer
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.58
     frame #0: 0x00000001d90eabf0 DirectResource`DRMemoryResourceCopyBuffer
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.65
     frame #0: 0x00000001d90eacb0 DirectResource`DRMemoryResourceGetLength
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.65
     frame #0: 0x00000001d90eacb0 DirectResource`DRMemoryResourceGetLength
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.60
     frame #0: 0x00000001d90eabbc DirectResource`DRMemoryResourceCreate
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.64
     frame #0: 0x00000001d90eacc4 DirectResource`DRMemoryResourceGetBytes
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.65
     frame #0: 0x00000001d90eacb0 DirectResource`DRMemoryResourceGetLength
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.63
     frame #0: 0x00000001d90eacd4 DirectResource`DRMemoryResourceDidUpdateBytes
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.60
     frame #0: 0x00000001d90eabbc DirectResource`DRMemoryResourceCreate
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.64
     frame #0: 0x00000001d90eacc4 DirectResource`DRMemoryResourceGetBytes
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.65
     frame #0: 0x00000001d90eacb0 DirectResource`DRMemoryResourceGetLength
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.63
     frame #0: 0x00000001d90eacd4 DirectResource`DRMemoryResourceDidUpdateBytes
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.66
     frame #0: 0x00000001d90eac9c DirectResource`DRMemoryResourceIsPrivateToProcess
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.65
     frame #0: 0x00000001d90eacb0 DirectResource`DRMemoryResourceGetLength
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.65
     frame #0: 0x00000001d90eacb0 DirectResource`DRMemoryResourceGetLength
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.58
     frame #0: 0x00000001d90eabf0 DirectResource`DRMemoryResourceCopyBuffer
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.58
     frame #0: 0x00000001d90eabf0 DirectResource`DRMemoryResourceCopyBuffer
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.65
     frame #0: 0x00000001d90eacb0 DirectResource`DRMemoryResourceGetLength
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.65
     frame #0: 0x00000001d90eacb0 DirectResource`DRMemoryResourceGetLength
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.60
     frame #0: 0x00000001d90eabbc DirectResource`DRMemoryResourceCreate
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.64
     frame #0: 0x00000001d90eacc4 DirectResource`DRMemoryResourceGetBytes
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.65
     frame #0: 0x00000001d90eacb0 DirectResource`DRMemoryResourceGetLength
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.63
     frame #0: 0x00000001d90eacd4 DirectResource`DRMemoryResourceDidUpdateBytes
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.60
     frame #0: 0x00000001d90eabbc DirectResource`DRMemoryResourceCreate
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.64
     frame #0: 0x00000001d90eacc4 DirectResource`DRMemoryResourceGetBytes
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.65
     frame #0: 0x00000001d90eacb0 DirectResource`DRMemoryResourceGetLength
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.63
     frame #0: 0x00000001d90eacd4 DirectResource`DRMemoryResourceDidUpdateBytes
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.66
     frame #0: 0x00000001d90eac9c DirectResource`DRMemoryResourceIsPrivateToProcess
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.65
     frame #0: 0x00000001d90eacb0 DirectResource`DRMemoryResourceGetLength
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.65
     frame #0: 0x00000001d90eacb0 DirectResource`DRMemoryResourceGetLength
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.58
     frame #0: 0x00000001d90eabf0 DirectResource`DRMemoryResourceCopyBuffer
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.58
     frame #0: 0x00000001d90eabf0 DirectResource`DRMemoryResourceCopyBuffer
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.65
     frame #0: 0x00000001d90eacb0 DirectResource`DRMemoryResourceGetLength
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.65
     frame #0: 0x00000001d90eacb0 DirectResource`DRMemoryResourceGetLength
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.60
     frame #0: 0x00000001d90eabbc DirectResource`DRMemoryResourceCreate
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.64
     frame #0: 0x00000001d90eacc4 DirectResource`DRMemoryResourceGetBytes
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.65
     frame #0: 0x00000001d90eacb0 DirectResource`DRMemoryResourceGetLength
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.63
     frame #0: 0x00000001d90eacd4 DirectResource`DRMemoryResourceDidUpdateBytes
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.60
     frame #0: 0x00000001d90eabbc DirectResource`DRMemoryResourceCreate
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.64
     frame #0: 0x00000001d90eacc4 DirectResource`DRMemoryResourceGetBytes
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.65
     frame #0: 0x00000001d90eacb0 DirectResource`DRMemoryResourceGetLength
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.63
     frame #0: 0x00000001d90eacd4 DirectResource`DRMemoryResourceDidUpdateBytes
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.66
     frame #0: 0x00000001d90eac9c DirectResource`DRMemoryResourceIsPrivateToProcess
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.65
     frame #0: 0x00000001d90eacb0 DirectResource`DRMemoryResourceGetLength
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.65
     frame #0: 0x00000001d90eacb0 DirectResource`DRMemoryResourceGetLength
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.58
     frame #0: 0x00000001d90eabf0 DirectResource`DRMemoryResourceCopyBuffer
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.58
     frame #0: 0x00000001d90eabf0 DirectResource`DRMemoryResourceCopyBuffer
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.65
     frame #0: 0x00000001d90eacb0 DirectResource`DRMemoryResourceGetLength
  bt 1
 * thread #11, name = 'Task 1', queue = 'com.apple.main-thread', stop reason = breakpoint 3.65
     frame #0: 0x00000001d90eacb0 DirectResource`DRMemoryResourceGetLength
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.49
     frame #0: 0x00000001d90e9d20 DirectResource`DRContextHasOpenCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.31
     frame #0: 0x00000001d90e9d74 DirectResource`DRContextCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.49
     frame #0: 0x00000001d90e9d20 DirectResource`DRContextHasOpenCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.31
     frame #0: 0x00000001d90e9d74 DirectResource`DRContextCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.49
     frame #0: 0x00000001d90e9d20 DirectResource`DRContextHasOpenCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.31
     frame #0: 0x00000001d90e9d74 DirectResource`DRContextCommit
 (label: Optional("imagePair"), value: RealityFoundation.ImagePresentationComponent.ImagePair(monoImage: RealityFoundation.ImagePresentationComponent.MonoImage(textureResource: RealityKit.TextureResource, orientation: __C.CGImagePropertyOrientation), spatialStereoImage: nil))
 (label: Optional("imageSource"), value: <CGImageSource: 0x120edcd50> 0x121a3df80 'public.jpeg')
 (label: Optional("monoIndex"), value: 0)
 (label: Optional("monoFocalLenIn35mmFilm"), value: Optional(24.0))
 (label: Optional("mxiSceneResource"), value: Optional(RealityFoundation.MXISceneResource))
 (label: Optional("registeredOwners"), value: Set([]))
 (label: Optional("generationProgress"), value: Optional(1.0))
 ---
 (label: Optional("sceneType"), value: RealityFoundation.MXISceneResource.MXISceneType.plane)
 (label: Optional("verticalFoV"), value: 0.9915555)
 (label: Optional("aspectRatio"), value: 1.3333334)
 (label: Optional("nearDistance"), value: 0.56248134)
 (label: Optional("farDistance"), value: 29.66007)
 (label: Optional("layerCount"), value: 64)
 (label: Optional("resolutionWidth"), value: 2048)
 (label: Optional("resolutionHeight"), value: 1536)
 (label: Optional("premultipliedAlpha"), value: false)
 (label: Optional("meshInternal"), value: 0x0000000121ab3b18)
 (label: Optional("textureInternal"), value: nil)
 (label: Optional("texturesInternal"), value: [0x0000000121ab2c18, 0x0000000121ab3618, 0x0000000121ab3118])
 (label: Optional("backgroundTextureInternal"), value: Optional(0x000000011e5d2218))
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.49
     frame #0: 0x00000001d90e9d20 DirectResource`DRContextHasOpenCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.31
     frame #0: 0x00000001d90e9d74 DirectResource`DRContextCommit

  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.49
     frame #0: 0x00000001d90e9d20 DirectResource`DRContextHasOpenCommit
 Missing some entity render options, this is an UNEXPECTED state. Make sure the scene is being tracked by the `RenderOptionsService`. Calling this method from  a handler for `RESceneEntityWillDeactivateEvent` or related can also cause this issue.
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.31
     frame #0: 0x00000001d90e9d74 DirectResource`DRContextCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.49
     frame #0: 0x00000001d90e9d20 DirectResource`DRContextHasOpenCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.31
     frame #0: 0x00000001d90e9d74 DirectResource`DRContextCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.49
     frame #0: 0x00000001d90e9d20 DirectResource`DRContextHasOpenCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.31
     frame #0: 0x00000001d90e9d74 DirectResource`DRContextCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.49
     frame #0: 0x00000001d90e9d20 DirectResource`DRContextHasOpenCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.31
     frame #0: 0x00000001d90e9d74 DirectResource`DRContextCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.49
     frame #0: 0x00000001d90e9d20 DirectResource`DRContextHasOpenCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.31
     frame #0: 0x00000001d90e9d74 DirectResource`DRContextCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.49
     frame #0: 0x00000001d90e9d20 DirectResource`DRContextHasOpenCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.31
     frame #0: 0x00000001d90e9d74 DirectResource`DRContextCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.49
     frame #0: 0x00000001d90e9d20 DirectResource`DRContextHasOpenCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.31
     frame #0: 0x00000001d90e9d74 DirectResource`DRContextCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.49
     frame #0: 0x00000001d90e9d20 DirectResource`DRContextHasOpenCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.31
     frame #0: 0x00000001d90e9d74 DirectResource`DRContextCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.49
     frame #0: 0x00000001d90e9d20 DirectResource`DRContextHasOpenCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.31
     frame #0: 0x00000001d90e9d74 DirectResource`DRContextCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.49
     frame #0: 0x00000001d90e9d20 DirectResource`DRContextHasOpenCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.31
     frame #0: 0x00000001d90e9d74 DirectResource`DRContextCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.49
     frame #0: 0x00000001d90e9d20 DirectResource`DRContextHasOpenCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.31
     frame #0: 0x00000001d90e9d74 DirectResource`DRContextCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.49
     frame #0: 0x00000001d90e9d20 DirectResource`DRContextHasOpenCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.31
     frame #0: 0x00000001d90e9d74 DirectResource`DRContextCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.49
     frame #0: 0x00000001d90e9d20 DirectResource`DRContextHasOpenCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.31
     frame #0: 0x00000001d90e9d74 DirectResource`DRContextCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.49
     frame #0: 0x00000001d90e9d20 DirectResource`DRContextHasOpenCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.31
     frame #0: 0x00000001d90e9d74 DirectResource`DRContextCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.49
     frame #0: 0x00000001d90e9d20 DirectResource`DRContextHasOpenCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.31
     frame #0: 0x00000001d90e9d74 DirectResource`DRContextCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.49
     frame #0: 0x00000001d90e9d20 DirectResource`DRContextHasOpenCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.31
     frame #0: 0x00000001d90e9d74 DirectResource`DRContextCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.49
     frame #0: 0x00000001d90e9d20 DirectResource`DRContextHasOpenCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.31
     frame #0: 0x00000001d90e9d74 DirectResource`DRContextCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.49
     frame #0: 0x00000001d90e9d20 DirectResource`DRContextHasOpenCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.31
     frame #0: 0x00000001d90e9d74 DirectResource`DRContextCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.49
     frame #0: 0x00000001d90e9d20 DirectResource`DRContextHasOpenCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.31
     frame #0: 0x00000001d90e9d74 DirectResource`DRContextCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.49
     frame #0: 0x00000001d90e9d20 DirectResource`DRContextHasOpenCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.31
     frame #0: 0x00000001d90e9d74 DirectResource`DRContextCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.49
     frame #0: 0x00000001d90e9d20 DirectResource`DRContextHasOpenCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.31
     frame #0: 0x00000001d90e9d74 DirectResource`DRContextCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.49
     frame #0: 0x00000001d90e9d20 DirectResource`DRContextHasOpenCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.31
     frame #0: 0x00000001d90e9d74 DirectResource`DRContextCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.49
     frame #0: 0x00000001d90e9d20 DirectResource`DRContextHasOpenCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.31
     frame #0: 0x00000001d90e9d74 DirectResource`DRContextCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.49
     frame #0: 0x00000001d90e9d20 DirectResource`DRContextHasOpenCommit
  bt 1
 * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.31
     frame #0: 0x00000001d90e9d74 DirectResource`DRContextCommit
 */
