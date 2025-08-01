#import <Foundation/Foundation.h>
#import <CoreRE/Defines.h>

NS_ASSUME_NONNULL_BEGIN

RE_EXTERN struct REComponentClass * RENetworkComponentGetComponentType(void);
RE_EXTERN void RENetworkMarkComponentDirty(struct REComponent *component);
RE_EXTERN void RENetworkMarkEntityMetadataDirty(struct REComponent *component);
RE_EXTERN uint64_t RENetworkComponentGuid(struct REComponent *component);
RE_EXTERN void RENetworkMarkComponentDirty(struct REComponent *component);

NS_ASSUME_NONNULL_END
