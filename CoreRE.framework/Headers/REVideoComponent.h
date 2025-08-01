#import <Foundation/Foundation.h>
#import <CoreRE/Defines.h>

NS_ASSUME_NONNULL_BEGIN

RE_EXTERN struct REComponentClass * REVideoComponentGetComponentType(void);
RE_EXTERN void REVideoComponentSetVideoAsset(struct REComponent *component, struct REAsset *videoAsset);
RE_EXTERN struct REAsset * _Nullable REVideoComponentGetVideoAsset(struct REComponent *component);

NS_ASSUME_NONNULL_END
