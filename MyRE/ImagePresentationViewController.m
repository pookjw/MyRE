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
                        
                        NSLog(@"%lld", [scene.vertexPositions length]); // 643072 (SIMD3)
                        NSLog(@"%lld", [scene.vertexUVs length]); // 321536 (SIMD2)
                        NSLog(@"%lld", [scene.triangleIndices length]); // 219504 (UInt32)
                        NSLog(@"%lld", [scene.triangleSliceIndices length]); // 73168 (UInt32)
                        
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
                            abort();
                        });
                        
                        
                        
                        // length = 114688
                        DRMeshUpdateIndices(drMesh, ^(void * _Nonnull bytes, long long length) {
                            uint16_t *dst = (uint16_t *)bytes;
                            const uint32_t *src = (const uint32_t *)scene.triangleIndices.contents;
                            NSUInteger count = length / sizeof(uint16_t);
                            for (NSUInteger i = 0; i < count; ++i) {
                                dst[i] = (uint16_t)(src[i] & 0xFFFF);
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
                         
                         NSLog(@"%lld", [scene.vertexPositions length]); // 643072 (SIMD3)
                         NSLog(@"%lld", [scene.vertexUVs length]); // 321536 (SIMD2)
                         NSLog(@"%lld", [scene.triangleIndices length]); // 219504 (UInt32)
                         NSLog(@"%lld", [scene.triangleSliceIndices length]); // 73168 (UInt32)
                         
                         // TODO
                         // length = 482304
                         DRMeshUpdateVertices(drMesh, 0, ^(void * _Nonnull bytes, long long length) {
                              RealityFoundationclosure #2 (Swift.UnsafeMutableRawBufferPointer) -> () in static RealityFoundation.MXISceneResource.createLowLevelMesh(mxiScene: __C.MXIScene) throws -> RealityFoundation.LowLevelMesh:
                              ->  0x1b031c4d4 <+0>:   pacibsp 
                                  0x1b031c4d8 <+4>:   sub    sp, sp, #0x60
                                  0x1b031c4dc <+8>:   stp    x24, x23, [sp, #0x20]
                                  0x1b031c4e0 <+12>:  stp    x22, x21, [sp, #0x30]
                                  0x1b031c4e4 <+16>:  stp    x20, x19, [sp, #0x40]
                                  0x1b031c4e8 <+20>:  stp    x29, x30, [sp, #0x50]
                                  0x1b031c4ec <+24>:  add    x29, sp, #0x50
                                  0x1b031c4f0 <+28>:  tbnz   x2, #0x3f, 0x1b031c578    ; <+164>
                                  0x1b031c4f4 <+32>:  mov    x20, x2
                                  0x1b031c4f8 <+36>:  cbz    x2, 0x1b031c55c           ; <+136>
                                  0x1b031c4fc <+40>:  ldr    x8, [x3, #0x10]
                                  0x1b031c500 <+44>:  cmp    x8, x20
                                  0x1b031c504 <+48>:  b.lo   0x1b031c57c               ; <+168>
                                  0x1b031c508 <+52>:  mov    x19, x4
                                  0x1b031c50c <+56>:  add    x21, x3, #0x20
                                  0x1b031c510 <+60>:  add    x22, x0, #0x8
                                  0x1b031c514 <+64>:  mov    x23, #-0x5555555555555556 ; =-6148914691236517206 
                                  0x1b031c518 <+68>:  movk   x23, #0x2aaa, lsl #48
                                  0x1b031c51c <+72>:  mov    w24, #0xc                 ; =12 
                                  0x1b031c520 <+76>:  ldr    q2, [x21]
                                  0x1b031c524 <+80>:  stur   d2, [x22, #-0x8]
                                  0x1b031c528 <+84>:  cbz    x23, 0x1b031c574          ; <+160>
                                  0x1b031c52c <+88>:  st1.s  { v2 }[2], [x22], x24
                                  0x1b031c530 <+92>:  ldp    q0, q1, [x19]
                                  0x1b031c534 <+96>:  bl     0x1b078eaa0
                                  0x1b031c538 <+100>: ldp    q3, q2, [sp]
                                  0x1b031c53c <+104>: mov.s  v0[3], v3[3]
                                  0x1b031c540 <+108>: mov.s  v1[3], v2[3]
                                  0x1b031c544 <+112>: sub    x23, x23, #0x1
                                  0x1b031c548 <+116>: stp    q0, q1, [x19]
                                  0x1b031c54c <+120>: add    x21, x21, #0x10
                                  0x1b031c550 <+124>: stp    q0, q1, [sp]
                                  0x1b031c554 <+128>: subs   x20, x20, #0x1
                                  0x1b031c558 <+132>: b.ne   0x1b031c520               ; <+76>
                                  0x1b031c55c <+136>: ldp    x29, x30, [sp, #0x50]
                                  0x1b031c560 <+140>: ldp    x20, x19, [sp, #0x40]
                                  0x1b031c564 <+144>: ldp    x22, x21, [sp, #0x30]
                                  0x1b031c568 <+148>: ldp    x24, x23, [sp, #0x20]
                                  0x1b031c56c <+152>: add    sp, sp, #0x60
                                  0x1b031c570 <+156>: retab  
                                  0x1b031c574 <+160>: brk    #0x1
                                  0x1b031c578 <+164>: brk    #0x1
                                  0x1b031c57c <+168>: brk    #0x1
                         });
                         
                         // length = 321536
                         DRMeshUpdateVertices(drMesh, 1, ^(void * _Nonnull bytes, long long length) {
                              RealityFoundationclosure #3 (Swift.UnsafeMutableRawBufferPointer) -> () in static RealityFoundation.MXISceneResource.createLowLevelMesh(mxiScene: __C.MXIScene) throws -> RealityFoundation.LowLevelMesh:
                              ->  0x1b031c580 <+0>:  tbnz   x2, #0x3f, 0x1b031c5bc    ; <+60>
                                  0x1b031c584 <+4>:  cbz    x2, 0x1b031c5b4           ; <+52>
                                  0x1b031c588 <+8>:  ldr    x8, [x3, #0x10]
                                  0x1b031c58c <+12>: cmp    x8, x2
                                  0x1b031c590 <+16>: b.lo   0x1b031c5c0               ; <+64>
                                  0x1b031c594 <+20>: add    x8, x3, #0x20
                                  0x1b031c598 <+24>: mov    x9, #-0x4000000000000000  ; =-4611686018427387904 
                                  0x1b031c59c <+28>: cbz    x9, 0x1b031c5b8           ; <+56>
                                  0x1b031c5a0 <+32>: ldr    d0, [x8, x9, lsl #3]
                                  0x1b031c5a4 <+36>: str    d0, [x0, x9, lsl #3]
                                  0x1b031c5a8 <+40>: add    x9, x9, #0x1
                                  0x1b031c5ac <+44>: subs   x2, x2, #0x1
                                  0x1b031c5b0 <+48>: b.ne   0x1b031c59c               ; <+28>
                                  0x1b031c5b4 <+52>: ret    
                                  0x1b031c5b8 <+56>: brk    #0x1
                                  0x1b031c5bc <+60>: brk    #0x1
                                  0x1b031c5c0 <+64>: brk    #0x1
                         });
                         
                         // length = 321536
                         DRMeshUpdateVertices(drMesh, 2, ^(void * _Nonnull bytes, long long length) {
                              RealityFoundationclosure #4 (Swift.UnsafeMutableRawBufferPointer) -> () in static RealityFoundation.MXISceneResource.createLowLevelMesh(mxiScene: __C.MXIScene) throws -> RealityFoundation.LowLevelMesh:
                              ->  0x1b031c5c4 <+0>:   tbnz   x2, #0x3f, 0x1b031c638    ; <+116>
                                  0x1b031c5c8 <+4>:   cbz    x2, 0x1b031c628           ; <+100>
                                  0x1b031c5cc <+8>:   mov    x8, #0x0                  ; =0 
                                  0x1b031c5d0 <+12>:  add    x9, x0, #0x4
                                  0x1b031c5d4 <+16>:  mov    w10, #0x24                ; =36 
                                  0x1b031c5d8 <+20>:  mov    x11, #0x4000000000000000  ; =4611686018427387904 
                                  0x1b031c5dc <+24>:  cmp    x8, x11
                                  0x1b031c5e0 <+28>:  b.eq   0x1b031c62c               ; <+104>
                                  0x1b031c5e4 <+32>:  ldr    x12, [x3]
                                  0x1b031c5e8 <+36>:  ldr    x13, [x12, #0x10]
                                  0x1b031c5ec <+40>:  cmp    x8, x13
                                  0x1b031c5f0 <+44>:  b.hs   0x1b031c630               ; <+108>
                                  0x1b031c5f4 <+48>:  add    x12, x12, x8, lsl #3
                                  0x1b031c5f8 <+52>:  ldr    d0, [x12, #0x20]
                                  0x1b031c5fc <+56>:  stur   s0, [x9, #-0x4]
                                  0x1b031c600 <+60>:  ldr    x12, [x3]
                                  0x1b031c604 <+64>:  ldr    x13, [x12, #0x10]
                                  0x1b031c608 <+68>:  cmp    x8, x13
                                  0x1b031c60c <+72>:  b.hs   0x1b031c634               ; <+112>
                                  0x1b031c610 <+76>:  add    x8, x8, #0x1
                                  0x1b031c614 <+80>:  ldr    s0, [x12, x10]
                                  0x1b031c618 <+84>:  str    s0, [x9], #0x8
                                  0x1b031c61c <+88>:  add    x10, x10, #0x8
                                  0x1b031c620 <+92>:  cmp    x2, x8
                                  0x1b031c624 <+96>:  b.ne   0x1b031c5dc               ; <+24>
                                  0x1b031c628 <+100>: ret    
                                  0x1b031c62c <+104>: brk    #0x1
                                  0x1b031c630 <+108>: brk    #0x1
                                  0x1b031c634 <+112>: brk    #0x1
                                  0x1b031c638 <+116>: brk    #0x1
                         });
                         
                         // length = 114688
                         DRMeshUpdateIndices(drMesh, ^(void * _Nonnull bytes, long long length) {
                              RealityFoundationpartial apply forwarder for closure #6 (Swift.UnsafeMutableRawBufferPointer) -> () in static RealityFoundation.MXISceneResource.createLowLevelMesh(mxiScene: __C.MXIScene) throws -> RealityFoundation.LowLevelMesh:
                              ->  0x1b0321d30 <+0>:  ldr    x9, [x20, #0x10]
                                  0x1b0321d34 <+4>:  ldr    x8, [x9, #0x10]
                                  0x1b0321d38 <+8>:  cbz    x8, 0x1b0321d58           ; <+40>
                                  0x1b0321d3c <+12>: add    x9, x9, #0x20
                                  0x1b0321d40 <+16>: ldr    w10, [x9], #0x4
                                  0x1b0321d44 <+20>: lsr    w11, w10, #16
                                  0x1b0321d48 <+24>: cbnz   w11, 0x1b0321d5c          ; <+44>
                                  0x1b0321d4c <+28>: strh   w10, [x0], #0x2
                                  0x1b0321d50 <+32>: subs   x8, x8, #0x1
                                  0x1b0321d54 <+36>: b.ne   0x1b0321d40               ; <+16>
                                  0x1b0321d58 <+40>: ret    
                                  0x1b0321d5c <+44>: brk    #0x1
                         });
 */
