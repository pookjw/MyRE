#import <Foundation/Foundation.h>
#import <CoreRE/Defines.h>
#import <ImageIO/ImageIO.h>

NS_ASSUME_NONNULL_BEGIN

RE_EXTERN struct REComponentClass * REImagePresentationComponentGetComponentType(void);
// RE_EXTERN void REImagePresentationComponentSetStereoImageTextureAsset(struct REComponent *component, struct REAsset *asset);
RE_EXTERN void REImagePresentationComponentSetMonoImageTextureAsset(struct REComponent *component, struct REAsset *asset);
RE_EXTERN struct REAsset * REImagePresentationComponentGetMonoImageTextureAsset(struct REComponent *component);
RE_EXTERN void REImagePresentationComponentSetStereoImageTextureAsset(struct REComponent *component, struct REAsset *asset);
RE_EXTERN struct REAsset * _Nullable REImagePresentationComponentGetStereoImageTextureAsset(struct REComponent *component);
RE_EXTERN void REImagePresentationComponentSetScreenHeight(struct REComponent *component, float height);
RE_EXTERN void REImagePresentationComponentSetImageContentType(struct REComponent *component, unsigned int contentType);
RE_EXTERN void REImagePresentationComponentSetContentDimensionHint(struct REComponent *component, float hint);
RE_EXTERN void REImagePresentationComponentSetLoadingImageTextureAsset(struct REComponent *component, struct REAsset * _Nullable asset);
RE_EXTERN void REImagePresentationComponentSetMonoImageOrientation(struct REComponent *component, CGImagePropertyOrientation orientation);
RE_EXTERN void REImagePresentationComponentSetStereoBaseline(struct REComponent *component, float baseline);
RE_EXTERN void REImagePresentationComponentSetDisparityAdjustment(struct REComponent *component, float adjustment);
RE_EXTERN void REImagePresentationComponentSetHorizontalFOV(struct REComponent *component, float fov);
RE_EXTERN void REImagePresentationComponentSetShouldLockMeshToImageAspectRatio(struct REComponent *component, BOOL shouldLock);
RE_EXTERN void REImagePresentationComponentSetCornerRadiusInPoints(struct REComponent *component, float radius);
RE_EXTERN void REImagePresentationComponentSetSpatial3DCollapseStrength(struct REComponent *component, float strength);
RE_EXTERN void REImagePresentationComponentSetStereoImageOrientation(struct REComponent *component, CGImagePropertyOrientation orientation);
RE_EXTERN void REImagePresentationComponentSetEnableSpecularAndFresnelEffects(struct REComponent *component, BOOL enabled);
RE_EXTERN void REImagePresentationComponentSetDesiredViewingMode(struct REComponent *component, unsigned int mode);
RE_EXTERN void REImagePresentationComponentSetDesiredImmersiveViewingMode(struct REComponent *component, unsigned int mode);
RE_EXTERN struct RESpatial3DImage * _Nullable REImagePresentationComponentGetSpatial3DImage(struct REComponent *component);
RE_EXTERN void REImagePresentationComponentSetSpatial3DImage(struct REComponent *component, struct RESpatial3DImage * _Nullable spatial3DImage);
RE_EXTERN void REImagePresentationComponentSetHasGeneratedSpatial3DImageContent(struct REComponent *component, BOOL hasGeneratedContent);
RE_EXTERN void REImagePresentationComponentSetMXITextureAssets(struct REComponent *component, CFArrayRef textureAssets);
RE_EXTERN void REImagePresentationComponentSetMXIBackgroundTextureAsset(struct REComponent *component, struct REAsset * _Nullable backgroundTextureAsset);
RE_EXTERN void REImagePresentationComponentSetMXIVerticalFOV(struct REComponent *component, float verticalFOV);
RE_EXTERN void REImagePresentationComponentSetMXIAspectRatio(struct REComponent *component, float aspectRatio);
RE_EXTERN void REImagePresentationComponentSetMXILayerCount(struct REComponent *component, unsigned int layerCount);
RE_EXTERN void REImagePresentationComponentSetMXIPremultipliedAlpha(struct REComponent *component, BOOL enabled);
RE_EXTERN void REImagePresentationComponentSetMXIResolutionWidth(struct REComponent *component, unsigned int width);
RE_EXTERN void REImagePresentationComponentSetMXIResolutionHeight(struct REComponent *component, unsigned int height);
RE_EXTERN void REImagePresentationComponentSetMXINearDistance(struct REComponent *component, float nearDistance);
RE_EXTERN void REImagePresentationComponentSetMXIFarDistance(struct REComponent *component, float farDistance);
RE_EXTERN void REImagePresentationComponentSetMXITextureAsset(struct REComponent *component, struct REAsset * _Nullable textureAsset);
RE_EXTERN void REImagePresentationComponentSetMXIMeshAsset(struct REComponent *component, struct REAsset * _Nullable meshAsset);

NS_ASSUME_NONNULL_END
