#import <Foundation/Foundation.h>
#import <CoreRE/Defines.h>

NS_ASSUME_NONNULL_BEGIN

RE_EXTERN struct REComponentClass * REUILayerGeometryComponentGetComponentType(void);
RE_EXTERN void REUILayerGeometryComponentSetWidth(struct REComponent *component, CGFloat width);
RE_EXTERN void REUILayerGeometryComponentSetHeight(struct REComponent *component, CGFloat height);

NS_ASSUME_NONNULL_END
