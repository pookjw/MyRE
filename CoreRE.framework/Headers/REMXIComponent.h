#import <Foundation/Foundation.h>
#import <CoreRE/Defines.h>

NS_ASSUME_NONNULL_BEGIN

RE_EXTERN struct REComponentClass * REMXIComponentGetComponentType(void);
RE_EXTERN void REMXIComponentSetSceneType(struct REComponent *component, int sceneType);
RE_EXTERN int REMXIComponentGetSceneType(struct REComponent *component);
RE_EXTERN void REMXIComponentSetRenderTwoPass(struct REComponent *component, BOOL renderTwoPass);
RE_EXTERN BOOL REMXIComponentGetRenderTwoPass(struct REComponent *component);
RE_EXTERN void REMXIComponentSetTexture(struct REComponent *component, struct REAsset * _Nullable textureAsset);
RE_EXTERN struct REAsset * _Nullable REMXIComponentGetTexture(struct REComponent *component);
RE_EXTERN void REMXIComponentSetTextures(struct REComponent *component, CFArrayRef _Nullable textureAssets);
RE_EXTERN CFArrayRef _Nullable REMXIComponentGetTextures(struct REComponent *component);
RE_EXTERN void REMXIComponentSetMesh(struct REComponent *component, struct REAsset * _Nullable meshAsset);
RE_EXTERN struct REAsset * _Nullable REMXIComponentGetMesh(struct REComponent *component);
RE_EXTERN void REMXIComponentSetRenderBackground(struct REComponent *component, BOOL renderBackground);
RE_EXTERN BOOL REMXIComponentGetRenderBackground(struct REComponent *component);
RE_EXTERN void REMXIComponentSetBackgroundTexture(struct REComponent *component, struct REAsset * _Nullable backgroundTextureAsset);
RE_EXTERN struct REAsset * _Nullable REMXIComponentGetBackgroundTexture(struct REComponent *component);
RE_EXTERN void REMXIComponentSetVerticalFoV(struct REComponent *component, float verticalFOV);
RE_EXTERN float REMXIComponentGetVerticalFoV(struct REComponent *component);
RE_EXTERN void REMXIComponentSetAspectRatio(struct REComponent *component, float aspectRatio);
RE_EXTERN float REMXIComponentGetAspectRatio(struct REComponent *component);
RE_EXTERN void REMXIComponentSetNearDistance(struct REComponent *component, float nearDistance);
RE_EXTERN float REMXIComponentGetNearDistance(struct REComponent *component);
RE_EXTERN void REMXIComponentSetFarDistance(struct REComponent *component, float farDistance);
RE_EXTERN float REMXIComponentGetFarDistance(struct REComponent *component);
RE_EXTERN void REMXIComponentSetLayerCount(struct REComponent *component, unsigned long layerCount);
RE_EXTERN unsigned long REMXIComponentGetLayerCount(struct REComponent *component);
RE_EXTERN void REMXIComponentSetResolutionWidth(struct REComponent *component, unsigned int width);
RE_EXTERN unsigned int REMXIComponentGetResolutionWidth(struct REComponent *component);
RE_EXTERN void REMXIComponentSetResolutionHeight(struct REComponent *component, unsigned int height);
RE_EXTERN unsigned int REMXIComponentGetResolutionHeight(struct REComponent *component);
RE_EXTERN void REMXIComponentSetPremultipliedAlpha(struct REComponent *component, BOOL enabled);
RE_EXTERN BOOL REMXIComponentGetPremultipliedAlpha(struct REComponent *component);
RE_EXTERN void REMXIComponentSetUseCustomMatrices(struct REComponent *component, BOOL useCustomMatrices);
RE_EXTERN BOOL REMXIComponentGetUseCustomMatrices(struct REComponent *component);
RE_EXTERN void REMXIComponentSetCustomProjectionMatrix(struct REComponent *component, simd_float4x4 projectionMatrix);
RE_EXTERN simd_float4x4 REMXIComponentGetCustomProjectionMatrix(struct REComponent *component);

NS_ASSUME_NONNULL_END
