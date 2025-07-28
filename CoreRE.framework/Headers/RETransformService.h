#import <Foundation/Foundation.h>
#import <CoreRE/Defines.h>
#include <simd/simd.h>

NS_ASSUME_NONNULL_BEGIN

RE_EXTERN struct RETransformService * _Nullable RETransformServiceFromEntity(struct REEntity *entity);
RE_EXTERN simd_float4x4 RETransformServiceGetWorldMatrix4x4F(struct RETransformService *service, struct REEntity *entity);
RE_EXTERN simd_float4x4 RETransformServiceGetParentWorldMatrix4x4F(struct RETransformService *service, struct REEntity *entity);

// Hidden
// RE_EXTERN simd_float4x4 RETransformServiceGetWorldUnanimatedMatrix4x4(struct RETransformService *service, struct REEntity *entity);
// RE_EXTERN simd_float4x4 RETransformServiceGetParentWorldUnanimatedMatrix4x4F(struct RETransformService *service, struct REEntity *entity);

NS_ASSUME_NONNULL_END
