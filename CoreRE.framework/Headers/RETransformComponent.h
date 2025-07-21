#import <Foundation/Foundation.h>
#import <CoreRE/REDefines.h>
#include <simd/simd.h>

NS_ASSUME_NONNULL_BEGIN

RE_EXTERN struct REComponentClass * RETransformComponentGetComponentType(void);
RE_EXTERN void RETransformComponentSetWorldMatrix4x4F(struct REComponent *, simd_float4x4);
RE_EXTERN simd_float4x4 RETransformComponentGetWorldMatrix4x4F(struct REComponent *);
RE_EXTERN simd_float4x4 RETransformComponentGetParentWorldMatrix4x4F(struct REComponent *);

NS_ASSUME_NONNULL_END
