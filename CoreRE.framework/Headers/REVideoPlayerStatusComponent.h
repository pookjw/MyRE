#import <Foundation/Foundation.h>
#import <CoreRE/Defines.h>

NS_ASSUME_NONNULL_BEGIN

RE_EXTERN struct REComponentClass * REVideoPlayerStatusComponentGetComponentType(void);
RE_EXTERN unsigned int REVideoPlayerStatusComponentGetCurrentImmersiveViewingMode(struct REComponent *component);
RE_EXTERN unsigned int REVideoPlayerStatusComponentGetCurrentSpatialVideoMode(struct REComponent *component);
RE_EXTERN unsigned int REVideoPlayerStatusComponentGetCurrentViewingMode(struct REComponent *component);

NS_ASSUME_NONNULL_END
