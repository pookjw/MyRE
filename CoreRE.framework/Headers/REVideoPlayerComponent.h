#import <Foundation/Foundation.h>
#import <CoreRE/Defines.h>

NS_ASSUME_NONNULL_BEGIN

RE_EXTERN struct REComponentClass * REVideoPlayerComponentGetComponentType(void);
RE_EXTERN void REVideoPlayerComponentSetVideoAsset(struct REComponent *component, struct REAsset *videoAsset);
RE_EXTERN struct REAsset * _Nullable REVideoPlayerComponentGetVideoAsset(struct REComponent *component);

NS_ASSUME_NONNULL_END
