#import <Foundation/Foundation.h>
#import <CoreRE/Defines.h>

NS_ASSUME_NONNULL_BEGIN

RE_EXTERN struct REComponentClass * REMXIComponentGetComponentType(void);
RE_EXTERN void REMXIComponentSetSceneType(struct REComponent *component, int sceneType);
RE_EXTERN int REMXIComponentGetSceneType(struct REComponent *component);

NS_ASSUME_NONNULL_END
