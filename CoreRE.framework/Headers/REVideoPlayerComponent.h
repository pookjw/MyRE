#import <Foundation/Foundation.h>
#import <CoreRE/Defines.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

RE_EXTERN struct REComponentClass * REVideoPlayerComponentGetComponentType(void);
RE_EXTERN void REVideoPlayerComponentSetVideoAsset(struct REComponent *component, struct REAsset *videoAsset);
RE_EXTERN struct REAsset * _Nullable REVideoPlayerComponentGetVideoAsset(struct REComponent *component);
RE_EXTERN void REVideoPlayerComponentSetScreenRoundedCornerEnabled(struct REComponent *component, BOOL enabled);
RE_EXTERN void REVideoPlayerComponentSetScaleRoundedCornerEnabled(struct REComponent *component, BOOL enabled);
RE_EXTERN void REVideoPlayerComponentSetScreenAspectRatioAnimationEnabled(struct REComponent *component, BOOL enabled);
RE_EXTERN void REVideoPlayerComponentSetScreenDeferAspectRatioTransitionToApp(struct REComponent *component, BOOL enabled);
RE_EXTERN void REVideoPlayerComponentSetGuid(struct REComponent *component, uint64_t guid);
RE_EXTERN uint64_t REVideoPlayerComponentGetGuid(struct REComponent *component);
//RE_EXTERN void REVideoPlayerComponentSetCaptionCALayer(struct REComponent *component, AVPlayerCaptionLayer * _Nullable captionLayer);
RE_EXTERN void REVideoPlayerComponentSetEnableSpecularAndFresnelEffects(struct REComponent *component, BOOL enabled);
RE_EXTERN void REVideoPlayerComponentSetBevelFrontDepth(struct REComponent *component, float depth);
RE_EXTERN void REVideoPlayerComponentSetEnableReflections(struct REComponent *component, BOOL enabled);
RE_EXTERN void REVideoPlayerComponentSetDesiredViewingMode(struct REComponent *component, unsigned int mode);
RE_EXTERN unsigned int REVideoPlayerComponentGetDesiredViewingMode(struct REComponent *component);
RE_EXTERN void REVideoPlayerComponentSetDesiredImmersiveViewingMode(struct REComponent *component, unsigned int mode);
RE_EXTERN unsigned int REVideoPlayerComponentGetDesiredImmersiveViewingMode(struct REComponent *component);
RE_EXTERN void REVideoPlayerComponentSetIsPassthroughTintingEnabled(struct REComponent *component, BOOL enabled);
RE_EXTERN BOOL REVideoPlayerComponentGetIsPassthroughTintingEnabled(struct REComponent *component);
RE_EXTERN void REVideoPlayerComponentSetIsMediaTintingEnabled(struct REComponent *component, BOOL enabled);
RE_EXTERN void REVideoPlayerComponentSetMaxGlowIntensity(struct REComponent *component, float intensity);
RE_EXTERN void REVideoPlayerComponentSetCaptionsOffset(struct REComponent *component, CGPoint offset);
RE_EXTERN void REVideoPlayerComponentSetIsAutoPauseOnHighMotionEnabled(struct REComponent *component, BOOL enabled);
RE_EXTERN void REVideoPlayerComponentSetDesiredSpatialVideoMode(struct REComponent *component, unsigned int mode);
RE_EXTERN unsigned int REVideoPlayerComponentGetDesiredSpatialVideoMode(struct REComponent *component);
RE_EXTERN void REVideoPlayerComponentSetLowLatencyEnabled(struct REComponent *component, BOOL enabled);
RE_EXTERN void REVideoPlayerComponentSetScreenWrapTheta(struct REComponent *component, BOOL enabled);
RE_EXTERN void REVideoPlayerComponentSetScreenWrapPostive(struct REComponent *component, BOOL enabled);
RE_EXTERN void REVideoPlayerComponentSetScreenWrapAnimation(struct REComponent *component, BOOL enabled);
RE_EXTERN void REVideoPlayerComponentSetUsesCurvedUIStyleSystemTreatments(struct REComponent *component, BOOL enabled);
RE_EXTERN void REVideoPlayerComponentSetScreenAspectRatio(struct REComponent *component, float aspectRatio);
RE_EXTERN void REVideoPlayerComponentSetLoadingTextureAspectRatioHint(struct REComponent *component, float aspectRatio);
RE_EXTERN void REVideoPlayerComponentSetLoadingTextureHorizontalFOVHint(struct REComponent *component, float fov);
RE_EXTERN void REVideoPlayerComponentSetSpatialGalleryRenderingEnabled(struct REComponent *component, BOOL enabled);
RE_EXTERN void REVideoPlayerComponentPreloadVideoAsset(struct REComponent *component);

NS_ASSUME_NONNULL_END
