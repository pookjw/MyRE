#import <Foundation/Foundation.h>
#import <CoreRE/Defines.h>
#include <simd/simd.h>

NS_ASSUME_NONNULL_BEGIN

RE_EXTERN struct REComponentClass * RETransformComponentGetComponentType(void);
RE_EXTERN void RETransformComponentSetWorldMatrix4x4F(struct REComponent *, simd_float4x4);
RE_EXTERN simd_float4x4 RETransformComponentGetWorldMatrix4x4F(struct REComponent *);
RE_EXTERN simd_float4x4 RETransformComponentGetParentWorldMatrix4x4F(struct REComponent *);
RE_EXTERN void RETransformComponentSetLocalScale(struct REComponent *, simd_float3 scale);
RE_EXTERN simd_float3 RETransformComponentGetLocalScale(struct REComponent *);
RE_EXTERN void RETransformComponentSetWorldScale(struct REComponent *, simd_float3 scale);
RE_EXTERN simd_float3 RETransformComponentGetWorldScale(struct REComponent *);
RE_EXTERN void RETransformComponentSetWorldPosition(struct REComponent *, simd_float3 position);
RE_EXTERN void RETransformComponentSetLocalSRT(struct REComponent *, simd_float4 scale, simd_float4 rotation, simd_float4 translation);

NS_ASSUME_NONNULL_END
