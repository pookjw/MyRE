#import <Foundation/Foundation.h>
#import <CoreRE/Defines.h>
#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

RE_EXTERN struct REComponentClass * RECALayerComponentGetComponentType(void);
RE_EXTERN void RECALayerComponentSetRespectsLayerTransform(struct REComponent *, BOOL);
RE_EXTERN void RECALayerComponentRootSetPointsPerMeter(struct REComponent *, float);
RE_EXTERN void RECALayerComponentSetShouldSyncToRemotes(struct REComponent *, BOOL);
RE_EXTERN CALayer * _Nullable RECALayerComponentGetCALayer(struct REComponent *);
RE_EXTERN void RECALayerComponentSetUpdatesMesh(struct REComponent *, BOOL);
RE_EXTERN void RECALayerComponentSetUpdatesMaterial(struct REComponent *, BOOL);
RE_EXTERN void RECALayerComponentSetUpdatesTexture(struct REComponent *, BOOL);
RE_EXTERN void RECALayerComponentSetUpdatesClippingPrimitive(struct REComponent *, BOOL);
RE_EXTERN CGSize RECALayerComponentGetLayerSize(struct REComponent *);

NS_ASSUME_NONNULL_END
