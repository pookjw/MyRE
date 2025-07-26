#import <Foundation/Foundation.h>
#import <CoreRE/Defines.h>

NS_ASSUME_NONNULL_BEGIN

RE_EXTERN void * RESceneAddEntity(struct REScene *scene, struct REEntity *entity);
RE_EXTERN id RESceneGetAllEntitiesArray(struct REScene *scene);

NS_ASSUME_NONNULL_END
