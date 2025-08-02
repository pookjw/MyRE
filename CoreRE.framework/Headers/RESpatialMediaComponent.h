#import <Foundation/Foundation.h>
#import <CoreRE/Defines.h>

NS_ASSUME_NONNULL_BEGIN

RE_EXTERN struct REComponentClass * RESpatialMediaComponentGetComponentType(void);
RE_EXTERN BOOL RESpatialMediaComponentGetIsFlatGeometry(struct REComponent *component);
RE_EXTERN void RESpatialMediaComponentSetIsFlatGeometry(struct REComponent *component, BOOL flag);

NS_ASSUME_NONNULL_END