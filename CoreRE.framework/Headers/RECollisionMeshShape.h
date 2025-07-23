#import <Foundation/Foundation.h>
#import <CoreRE/Defines.h>

NS_ASSUME_NONNULL_BEGIN

RE_EXTERN struct RECollisionMeshShape * RESphereShapeCreate(float radius);
RE_EXTERN struct RECollisionMesh * RECollisionMeshShapeGetMesh(struct RECollisionMeshShape *shape);

NS_ASSUME_NONNULL_END
