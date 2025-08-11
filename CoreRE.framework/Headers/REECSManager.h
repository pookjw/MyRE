#import <Foundation/Foundation.h>
#import <CoreRE/Defines.h>

NS_ASSUME_NONNULL_BEGIN

RE_EXTERN struct RERealityRendererSceneGroup * _Nullable REECSManagerCreateRealityRendererSceneGroup(struct REECSManager *ecsManager);
RE_EXTERN void REECSManagerAddSceneToRealityRendererSceneGroup(struct REECSManager *ecsManager, struct RERealityRendererSceneGroup *sceneGroup, struct REScene *scene);

NS_ASSUME_NONNULL_END
