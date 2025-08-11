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
#import <RealityFusion/RealityFusion.h>
#include <uuid/uuid.h>

@implementation ImagePresentationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view _requestSeparatedState:1 withReason:@"_UIViewSeparatedStateRequestReasonUnspecified"];
    
    struct REEntity *entity = [self.view _reEntity];
    struct REEntity *customEntity = REEntityCreate();
    REEntitySetParent(customEntity, entity);
    
    struct REComponent *transformComponent = REEntityGetOrAddComponentByClass(customEntity, RETransformComponentGetComponentType());
    RETransformComponentSetWorldPosition(transformComponent, simd_make_float3(0.f, 0.f, 0.1f));
    RETransformComponentSetLocalScale(transformComponent, simd_make_float3(0.3f, 0.3f, 0.3f));
    
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
                    struct REAsset * _Nullable colorTexture;
                    {
                        id<MTLTexture> _Nullable _colorTexture = scene.colorTexture;
                        if (_colorTexture) {
                            struct RETextureAssetData *data = RETextureAssetDataCreateWithTexture(_colorTexture, (CFDictionaryRef)@{
                                (id)kRETextureAssetCreateOptionSemantic: (id)kRETextureAssetCreateSemanticColor
                            });
                            colorTexture = REAssetManagerCreateTextureAssetFromData(MRUIDefaultAssetManager(), NULL, data);
                        } else {
                            colorTexture = nil;
                        }
                    }
                    
                    CFMutableArrayRef colorTextures;
                    {
                        NSArray<id<MTLTexture>> *_colorTextures = scene.colorTextures;
                        colorTextures = CFArrayCreateMutable(kCFAllocatorDefault, _colorTextures.count, NULL);
                        for (id<MTLTexture> texture in _colorTextures) {
                            struct RETextureAssetData *data = RETextureAssetDataCreateWithTexture(texture, (CFDictionaryRef)@{
                                (id)kRETextureAssetCreateOptionSemantic: (id)kRETextureAssetCreateSemanticColor
                            });
                            struct REAsset *colorTexture = REAssetManagerCreateTextureAssetFromData(MRUIDefaultAssetManager(), NULL, data);
                            CFArrayAppendValue(colorTextures, colorTexture);
                            RERelease(data);
                        }
                        
                        REImagePresentationComponentSetMXITextureAssets(imagePresentationComponent, colorTextures);
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
                        DRMeshDescriptorSetVertexAttributeFormat(descriptor, 2, 6, MTLVertexFormatFloat2, 2, 0);
                        DRMeshDescriptorSetVertexLayout(descriptor, 0, 0, 0, 12);
                        DRMeshDescriptorSetVertexLayout(descriptor, 1, 1, 0, 8);
                        DRMeshDescriptorSetVertexLayout(descriptor, 2, 2, 0, 8);
                        
                        struct DRContext *drContext = REServiceLocatorGetDirectResourceService(MRUIDefaultServiceLocator());
                        NSError * _Nullable error = nil;
                        struct DRMesh *drMesh = DRContextCreateMesh(drContext, descriptor, &error);
                        assert(drMesh != NULL);
                        DRRelease(descriptor);
                        DRMeshSetPartCount(drMesh, 1);
                        
                        __block struct DRBoundingBox boundingBox;
                        boundingBox.min = simd_make_float3(FLT_MAX, FLT_MAX, FLT_MAX);
                        boundingBox.max = simd_make_float3(-FLT_MAX, -FLT_MAX, -FLT_MAX);
                        
                        DRMeshUpdateVertices(drMesh, 0, ^(void * _Nonnull bytes, long long length) {
                            // x21
                            const simd_float3 *src = (const simd_float3 *)(scene.vertexPositions.contents);
                            MTLPackedFloat3 *dst = (MTLPackedFloat3 *)bytes;
                            
                            size_t vertexCount = scene.vertexPositions.length / sizeof(simd_float3);
                            for (size_t idx = 0; idx < vertexCount; idx++) {
                                simd_float3 point = src[idx];
                                dst[idx] = MTLPackedFloat3Make(point.x, point.y, point.z);
                                boundingBox = REAABBExpandedToIncludePoint(boundingBox.min, boundingBox.max, point);
                            }
                        });
                        
                        assert(DRMeshGetPartCount(drMesh) == 1);
                        DRMeshSetPartAt(drMesh, DRMeshGetPartCount(drMesh) - 1, scene.opaqueTriangleCount, scene.triangleCount * 3, MTLPrimitiveTypeTriangle, 0, boundingBox);
                        
                        DRMeshUpdateVertices(drMesh, 1, ^(void * _Nonnull bytes, long long length) {
                            memcpy(bytes, scene.vertexUVs.contents, length);
                        });
                        
                        DRMeshUpdateVertices(drMesh, 2, ^(void * _Nonnull bytes, long long length) {
                            const simd_float3 *vertexPositions = (const simd_float3 *)scene.vertexPositions.contents;
                            const uint32_t *triIndices = (const uint32_t *)scene.triangleIndices.contents;
                            const uint32_t *slice = (const uint32_t *)scene.triangleSliceIndices.contents;
                            simd_float2 *dst = (simd_float2 *)bytes;
                            
                            const size_t triCount = scene.triangleCount;
                            for (size_t t = 0; t < triCount; ++t) {
                                const uint32_t i0 = triIndices[t * 3 + 0];
                                const uint32_t i1 = triIndices[t * 3 + 1];
                                const uint32_t i2 = triIndices[t * 3 + 2];
                                
                                if (i0 >= scene.vertexCount || i1 >= scene.vertexCount || i2 >= scene.vertexCount) {
                                    abort();
                                }
                                
                                const float triId = (float)slice[t];
                                
                                simd_float3 a0 = simd_abs(vertexPositions[i0]);
                                simd_float3 a1 = simd_abs(vertexPositions[i1]);
                                simd_float3 a2 = simd_abs(vertexPositions[i2]);
                                
                                float v0, v1, v2;
                                if (scene.type != 0) {
                                    v0 = fminf(fminf(a0.x, a0.y), a0.z);
                                    v1 = fminf(fminf(a1.x, a1.y), a1.z);
                                    v2 = fmaxf(fmaxf(a2.x, a2.y), a2.z);
                                } else {
                                    v0 = a0.z; v1 = a1.z; v2 = a2.z;
                                }
                                
                                dst[i0] = simd_make_float2(triId, v0);
                                dst[i1] = simd_make_float2(0.f, v1);
                                dst[i2] = simd_make_float2(0.f, v2);
                            }
                        });
                        
                        DRMeshUpdateIndices(drMesh, ^(void * _Nonnull bytes, long long length) {
                            const uint32_t *src = (const uint32_t *)scene.triangleIndices.contents;
                            uint16_t *dst = (uint16_t *)bytes;
                            
                            NSUInteger count = length / sizeof(uint16_t);
                            for (NSUInteger idx = 0; idx < count; idx++) {
                                dst[idx] = (uint16_t)src[idx];
                            }
                        });
                        
                        struct REAsset *meshAsset = REAssetManagerCreateMeshAssetWithDirectMesh(MRUIDefaultAssetManager(), drMesh);
                        DRRelease(drMesh);
                        REImagePresentationComponentSetMXIMeshAsset(imagePresentationComponent, meshAsset);
                        RERelease(meshAsset);
                        
                        //
                        
//                        {
//                            MTLTextureDescriptor *descriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatBGRA8Unorm_sRGB width:64 height:64 mipmapped:NO];
//                            id<MTLDevice> device = MTLCreateSystemDefaultDevice();
//                            id<MTLTexture> texture = [device newTextureWithDescriptor:descriptor];
//                            [device release];
//                            [ImagePresentationViewController renderMXIBackgroundWithMesh:meshAsset texture:colorTexture textures:colorTextures sceneType:scene.type verticalFoV:scene.verticalFOV aspectRatio:scene.aspectRatio nearDistance:scene.depthRange.near farDistance:scene.depthRange.far layerCount:scene.numLayers resoluationWidth:scene.resolutionWidth resoluationHeight:scene.resolutionHeight isPremultipliedAlpha:scene.isPremultipliedAlpha toBackgroundTexture:texture];
//                            RERelease(meshAsset);
//                            
//                            struct RETextureAssetData *colorTextureAssetData = RETextureAssetDataCreateWithTexture(texture, (CFDictionaryRef)@{
//                                (id)kRETextureAssetCreateOptionSemantic: (id)kRETextureAssetCreateSemanticColor
//                            });
//                            [texture release];
//                            struct REAsset *colorTexture = REAssetManagerCreateTextureAssetFromData(MRUIDefaultAssetManager(), NULL, colorTextureAssetData);
//                            RERelease(colorTextureAssetData);
//                            REImagePresentationComponentSetMXIBackgroundTextureAsset(imagePresentationComponent, colorTexture);
//                            RERelease(colorTexture);
//                        }
                        REImagePresentationComponentSetMXITextureAsset(imagePresentationComponent, NULL);
                    }
                    
                    if (colorTexture) {
                        RERelease(colorTexture);
                    }
                    {
                        CFIndex count = CFArrayGetCount(colorTextures);
                        for (CFIndex idx = 0; idx < count; idx++) {
                            struct REAsset *texture = (struct REAsset *)CFArrayGetValueAtIndex(colorTextures, idx);
                            RERelease(texture);
                        }
                        CFRelease(colorTextures);
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

+ (void)renderMXIBackgroundWithMesh:(struct REAsset *)mesh texture:(struct REAsset * _Nullable)texture textures:(CFArrayRef)textures sceneType:(long)sceneType verticalFoV:(float)verticalFoV aspectRatio:(float)aspectRatio nearDistance:(float)nearDistance farDistance:(float)farDistance layerCount:(unsigned long)layerCount resoluationWidth:(unsigned int)resoluationWidth resoluationHeight:(unsigned int)resoluationHeight isPremultipliedAlpha:(BOOL)isPremultipliedAlpha toBackgroundTexture:(id<MTLTexture>)backgroundTexture {
    // $s17RealityFoundation16MXISceneResourceC19renderMXIBackground33_1E3AB1A79F9B511C8133C7993194CC62LL4mesh7texture8textures9sceneType11verticalFoV11aspectRatio12nearDistance03farY019toBackgroundTextureys13OpaquePointerV_APSgSayAPGAC0cS0OS4fSo10MTLTexture_ptKFZTf4nnnnnnnnnd_n
    // x27
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    // x25
    id<MTLSharedEvent> event = [device newSharedEvent];
    // x22
    struct REEntity *entity = REEntityCreate();
    struct REComponent *perspectiveCameraComponent = REEntityGetOrAddComponentByClass(entity, REPerspectiveCameraComponentGetComponentType());
    struct REComponent *tramsformComponent = REEntityGetOrAddComponentByClass(entity, RETransformComponentGetComponentType());
    RETransformComponentSetLocalSRT(tramsformComponent, simd_make_float3(1.f, 1.f, 1.f), simd_make_float3(0.f, 0.f, 0.f), simd_make_float3(0.f, 0.f, 0.f));
    
    CGColorRef color = CGColorCreateGenericRGB(0., 0., 0., 0.);
    
    struct REEntity *childEntity = REEntityCreate();
    struct REComponent *childTramsformComponent = REEntityGetOrAddComponentByClass(childEntity, RETransformComponentGetComponentType());
    RETransformComponentSetLocalSRT(childTramsformComponent, simd_make_float3(1.f, 1.f, 1.f), simd_make_float3(0.f, 0.f, 0.f), simd_make_float3(0.f, 0.f, 0.f));
    struct REComponent *childMXIComponent = REEntityGetOrAddComponentByClass(childEntity, REMXIComponentGetComponentType());
    REMXIComponentSetMesh(childMXIComponent, mesh);
    REMXIComponentSetTexture(childMXIComponent, texture);
    REMXIComponentSetTextures(childMXIComponent, textures);
    REMXIComponentSetRenderBackground(childMXIComponent, YES);
    if (texture) {
        REMXIComponentSetBackgroundTexture(childMXIComponent, texture);
    }
    REMXIComponentSetSceneType(childMXIComponent, (int)sceneType);
    REMXIComponentSetVerticalFoV(childMXIComponent, verticalFoV);
    REMXIComponentSetAspectRatio(childMXIComponent, aspectRatio);
    REMXIComponentSetNearDistance(childMXIComponent, nearDistance);
    REMXIComponentSetFarDistance(childMXIComponent, farDistance);
    REMXIComponentSetLayerCount(childMXIComponent, layerCount);
    REMXIComponentSetResolutionWidth(childMXIComponent, resoluationWidth);
    REMXIComponentSetResolutionHeight(childMXIComponent, resoluationHeight);
    REMXIComponentSetPremultipliedAlpha(childMXIComponent, isPremultipliedAlpha);
    REMXIComponentSetRenderTwoPass(childMXIComponent, YES);
    
    if (!REMXIComponentGetRenderTwoPass(childMXIComponent)) {
        abort();
    }
    
    struct REEngine *engine = REEngineGetShared();
    struct REServiceLocator *serviceLocator = REEngineGetServiceLocator(engine);
    struct REAssetManager *assetManager = REServiceLocatorGetAssetManager(serviceLocator);
    struct REAsset *emitterAsset = REAssetManagerCreateAssetHandle(assetManager, "engine:BuiltinRenderGraphResources/SimpleForward/simpleForwardCombinedPost.rerendergraphemitter");
    struct RERenderManager *renderManager = REServiceLocatorGetRenderManager(serviceLocator);
    RERenderGraphEmitterPreloadProvidersAssets(emitterAsset, renderManager);
    RERenderGraphEmitterAssetRegisterProviders(emitterAsset, renderManager);
    struct REECSManager *ecsManager = REServiceLocatorGetECSService(serviceLocator);
    struct RERealityRendererSceneGroup *sceneGroup = REECSManagerCreateRealityRendererSceneGroup(ecsManager);
    assert(sceneGroup != NULL);
    struct REScene *scene = RESceneCreate("RealityRenderer.scene-1");
    REECSManagerAddSceneToRealityRendererSceneGroup(ecsManager, sceneGroup, scene);
    
    struct REEngineOverlay *overlay = REEngineCreateOverlayForRealityRenderer(engine);
    REEngineOverlaySetRealityRendererSceneGroup(overlay, sceneGroup);
    
    struct REAssetHandle *noDepthAsset = REAssetManagerCreateAssetHandle(assetManager, "engine:BuiltinRenderGraphResources/Common/realityRendererCameraNoDepth.rerendergraph");
    struct REAssetHandle *noColorAsset = REAssetManagerCreateAssetHandle(assetManager, "engine:BuiltinRenderGraphResources/Common/realityRendererCameraNoColor.rerendergraph");
    struct REAssetHandle *postProcessAsset = REAssetManagerCreateAssetHandle(assetManager, "engine:BuiltinRenderGraphResources/Common/realityRendererPostProcess.rerendergraph");
    struct REAssetHandle *backgroundAsset = REAssetManagerCreateAssetHandle(assetManager, "engine:BuiltinRenderGraphResources/Common/realityRendererBackground.rematerialdefinition");
    struct REAssetHandle *postProcessTonemapInplaceAsset = REAssetManagerCreateAssetHandle(assetManager, "engine:BuiltinRenderGraphResources/Common/realityRendererPostProcessTonemapInplace.rerendergraph");
    
    REAssetHandleLoadAsync(noDepthAsset);
    REAssetHandleLoadAsync(noColorAsset);
    struct REEngineConfiguration *engineConfiguration = REEngineConfigurationCreateFromEngine(engine);
    if (REEngineConfigurationGetEnablePreloadEngineAssets(engineConfiguration)) {
        REAssetHandleLoadAsync(postProcessAsset);
        REAssetHandleLoadAsync(backgroundAsset);
        REAssetHandleLoadAsync(postProcessTonemapInplaceAsset);
    }
    
    if (REEngineConfigurationIsSolariumLeanModeEnabled(engineConfiguration)) {
        struct REComponent *anchorComponent = REEntityGetOrAddComponentByClass(scene, REAnchorComponentGetComponentType());
        REAnchorComponentSetAnchoredLocally(anchorComponent, YES);
    } else {
        struct RFServiceManager *serviceManager = RFServiceManagerCreate();
        struct RFMeshReconstructionService *meshReconstructionService = RFMeshReconstructionServiceCreate();
        RFServiceManagerSetMeshReconstructionService(serviceManager, meshReconstructionService);
        struct RFAnchorManagementService *anchorManagementService = RFAnchorManagementServiceCreate();
        RFServiceManagerSetAnchorManagementService(serviceManager, anchorManagementService);
        struct RFLoggingService *loggingService = RFLoggingServiceCreate();
        RFServiceManagerSetLoggingService(serviceManager, loggingService);
        struct RFEnvironmentProbePlacementService *environmentProbePlacementService = RFEnvironmentProbePlacementServiceCreate();
        RFServiceManagerSetEnvironmentProbePlacementService(serviceManager, environmentProbePlacementService);
        struct RFAtmospherePlacementService *atmospherePlacementServiceCreate = RFAtmospherePlacementServiceCreate();
        RFServiceManagerSetAtmospherePlacementService(serviceManager, atmospherePlacementServiceCreate);
        struct RFAnchorDataProvider *anchorDataProvider = RFAnchorDataProviderCreate();
        RFServiceManagerSetAnchorDataProvider(serviceManager, anchorDataProvider);
    }
    
    struct REEntity *sceneUnderstandingRootEntity = REEntityCreate();
    REEntitySetName(sceneUnderstandingRootEntity, "Scene Understanding Root Entity");
    {
        struct REComponent *anchorComponent = REEntityGetOrAddComponentByClass(sceneUnderstandingRootEntity, REAnchorComponentGetComponentType());
        REAnchorComponentSetAnchoredLocally(anchorComponent, YES);
        REEntityGetOrAddComponentByClass(sceneUnderstandingRootEntity, RESceneUnderstandingRenderOptionsComponentGetComponentType());
        RESceneAddEntity(scene, sceneUnderstandingRootEntity);
        REHideEntity(sceneUnderstandingRootEntity);
        
        // Ninja
        uuid_t anchorIdentifier;
        uuid_generate_random((unsigned char *)&anchorIdentifier);
        REAnchorComponentSetAnchorIdentifier(anchorComponent, anchorIdentifier);
        REAnchorComponentSetWorldTransform(anchorComponent, matrix_identity_float4x4);
        REEntityAddComponentNoEvents(sceneUnderstandingRootEntity, RETransformComponentGetComponentType());
        REEntitySendAddAndActivateComponentEvents(sceneUnderstandingRootEntity, RETransformComponentGetComponentType());
    }
    
    if (REEngineConfigurationGetEnablePreloadMXIAssets(engineConfiguration)) {
        if (REAssetManagerIsLoading(assetManager)) {
            REAssetManagerUpdate(assetManager);
            
            if (REAssetManagerIsLoading(assetManager)) {
                usleep(1000);
                REAssetManagerUpdate(assetManager);
                
                if (REAssetManagerIsLoading(assetManager)) {
                    usleep(1000);
                    REAssetManagerUpdate(assetManager);
                    
                    if (REAssetManagerIsLoading(assetManager)) {
                        usleep(1000);
                        REAssetManagerUpdate(assetManager);
                        
                        if (REAssetManagerIsLoading(assetManager)) {
                            usleep(1000);
                            REAssetManagerUpdate(assetManager);
                            
                            if (REAssetManagerIsLoading(assetManager)) {
                                usleep(1000);
                                REAssetManagerUpdate(assetManager);
                                
                                if (REAssetManagerIsLoading(assetManager)) {
                                    usleep(1000);
                                    REAssetManagerUpdate(assetManager);
                                    
                                    if (REAssetManagerIsLoading(assetManager)) {
                                        usleep(1000);
                                        REAssetManagerUpdate(assetManager);
                                        
                                        if (REAssetManagerIsLoading(assetManager)) {
                                            usleep(1000);
                                            REAssetManagerUpdate(assetManager);
                                            
                                            if (REAssetManagerIsLoading(assetManager)) {
                                                usleep(1000);
                                                REAssetManagerUpdate(assetManager);
                                                
                                                if (REAssetManagerIsLoading(assetManager)) {
                                                    usleep(1000);
                                                    REAssetManagerUpdate(assetManager);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    
    //
    
//    struct REDrawingManager *drawingManager = REEngineCreateDrawingManager(engine);
    assert(!REEngineOverlayIsEngineInsideTick(overlay));
    
//    struct REComponent *cameraViewDescriptorsComponent = REEntityGetOrAddComponentByClass(sceneUnderstandingRootEntity, RECameraViewDescriptorsComponentGetComponentType());
//    RECameraViewDescriptorsComponentClearCameraViewDescriptors(cameraViewDescriptorsComponent);
//    struct REComponent *graphFileProviderArrayComponent = REEntityGetOrAddComponentByClass(sceneUnderstandingRootEntity, RERenderGraphFileProviderArrayComponentGetComponentType());
//    RERenderGraphFileProviderArrayComponentRemoveAll(graphFileProviderArrayComponent);
    
    RENetworkMarkComponentDirty(childMXIComponent);
    REEngineOverlayEnterFrame(overlay, 1.f / 30.f);
    REEngineOverlayFramePrepare(overlay);
    REEngineOverlayFrameSimulate(overlay);
    REEngineOverlayFrameCommit(overlay);
    REEngineOverlayFrameExit(overlay);
    
    NSLog(@"%@", backgroundTexture);
}

@end
