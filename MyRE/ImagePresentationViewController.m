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
    
    struct REComponent *imagePresentationComponent = REEntityGetOrAddComponentByClass(customEntity, REImagePresentationComponentGetComponentType());
    REImagePresentationComponentSetScreenHeight(imagePresentationComponent, 1.f);
    REImagePresentationComponentSetImageContentType(imagePresentationComponent, 2);
    REImagePresentationComponentSetContentDimensionHint(imagePresentationComponent, 0.f);
    REImagePresentationComponentSetLoadingImageTextureAsset(imagePresentationComponent, NULL);
    REImagePresentationComponentSetStereoBaseline(imagePresentationComponent, 19.272f);
    REImagePresentationComponentSetDisparityAdjustment(imagePresentationComponent, 0.024f);
    REImagePresentationComponentSetHorizontalFOV(imagePresentationComponent, 68.5f);
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
    
    NSURL *url = [NSBundle.mainBundle URLForResource:@"spatial_image" withExtension:UTTypeHEIC.preferredFilenameExtension];
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
        
        unsigned int primaryImageIndex = (unsigned int)CGImageSourceGetPrimaryImageIndex(imageSource);
        
        if (stereoPairGroup == nil) {
            struct REAsset *monoAsset = [self newMonoTextureAssetWithImageSource:imageSource index:primaryImageIndex];
            REImagePresentationComponentSetMonoImageTextureAsset(imagePresentationComponent, monoAsset);
            RERelease(monoAsset);
            CFRelease(imageSource);
            return;
        }
        
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
            if (imageIndex.unsignedIntValue == primaryImageIndex) {
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
        
        struct REAsset *monoAsset = [self newMonoTextureAssetWithImageSource:imageSource index:primaryImageIndex];
        REImagePresentationComponentSetMonoImageTextureAsset(imagePresentationComponent, monoAsset);
        RERelease(monoAsset);
        
        struct REAsset *stereoAsset = [self newStereoTextureAssetWithImageSource:imageSource leftIndex:leftImageIndex rightIndex:rightImageIndex];
        REImagePresentationComponentSetMonoImageTextureAsset(imagePresentationComponent, stereoAsset);
        RERelease(stereoAsset);
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
