#import <Foundation/Foundation.h>
#import <CoreRE/Defines.h>

NS_ASSUME_NONNULL_BEGIN

RE_EXTERN struct REComponentClass * RECALayerClientComponentGetComponentType(void);
RE_EXTERN CALayer * _Nullable RECALayerClientComponentGetCALayer(struct REComponent *);
RE_EXTERN struct REComponent * _Nullable RECALayerGetCALayerClientComponent(CALayer *);
RE_EXTERN void RECALayerClientComponentSetRespectsLayerTransform(struct REComponent *, BOOL);
RE_EXTERN void RECALayerClientComponentSetShouldSyncToRemotes(struct REEntity *, BOOL); // -[UIView _requestSeparatedState:withReason:]
RE_EXTERN void RECALayerClientComponentSetUpdatesMesh(struct REComponent *, BOOL);
RE_EXTERN void RECALayerClientComponentSetUpdatesMaterial(struct REComponent *, BOOL);
RE_EXTERN void RECALayerClientComponentSetUpdatesTexture(struct REComponent *, BOOL);
RE_EXTERN void RECALayerClientComponentSetUpdatesClippingPrimitive(struct REComponent *, BOOL);

NS_ASSUME_NONNULL_END
