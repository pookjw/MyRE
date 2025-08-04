#import <Foundation/Foundation.h>
#import <CoreRE/Defines.h>
#import <Metal/Metal.h>
#include <simd/simd.h>

NS_ASSUME_NONNULL_BEGIN

RE_EXTERN simd_float3 RETextureAssetGetSize(struct REAsset *asset);
RE_EXTERN struct RETextureAssetData * RETextureAssetDataCreateWithTexture(id<MTLTexture> texture, CFDictionaryRef options);

NS_ASSUME_NONNULL_END
