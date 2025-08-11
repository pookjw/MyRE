#import <Foundation/Foundation.h>
#import <CoreRE/Defines.h>
#include <uuid/uuid.h>
#include <simd/simd.h>

NS_ASSUME_NONNULL_BEGIN

RE_EXTERN struct REComponentClass * REAnchorComponentGetComponentType(void);
RE_EXTERN void REAnchorComponentSetAnchoredLocally(struct REComponent *component, BOOL anchored);
RE_EXTERN void REAnchorComponentSetAnchorIdentifier(struct REComponent *component, uuid_t anchorIdentifier);
RE_EXTERN void REAnchorComponentSetWorldTransform(struct REComponent *component, simd_float4x4 worldTransform);

NS_ASSUME_NONNULL_END
