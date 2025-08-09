#import <Foundation/Foundation.h>
#import <CoreRE/Defines.h>
#import <DirectResource/Defines.h>

NS_ASSUME_NONNULL_BEGIN

RE_EXTERN void RERetain(const void *);
RE_EXTERN void RERelease(const void *);
RE_EXTERN NSUInteger REGetRetainCount(const void *);
RE_EXTERN struct DRBoundingBox REAABBExpandedToIncludePoint(simd_float3 min, simd_float3 max, simd_float3 point);

NS_ASSUME_NONNULL_END
