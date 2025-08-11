#import <Foundation/Foundation.h>
#import <CoreRE/Defines.h>

NS_ASSUME_NONNULL_BEGIN

RE_EXTERN struct REComponentClass * REPerspectiveCameraComponentGetComponentType(void);
RE_EXTERN void REPerspectiveCameraComponentSetNear(struct REComponent *component, float near);
RE_EXTERN void REPerspectiveCameraComponentSetFar(struct REComponent *component, float far);
RE_EXTERN void REPerspectiveCameraComponentSetFieldOfView(struct REComponent *component, float fov);
RE_EXTERN void REPerspectiveCameraComponentSetFieldOfViewDirection(struct REComponent *component, float fovDirection);

NS_ASSUME_NONNULL_END
