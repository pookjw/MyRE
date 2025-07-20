#import <Foundation/Foundation.h>
#import <CoreRE/REDefines.h>

NS_ASSUME_NONNULL_BEGIN

RE_EXTERN struct REGeomBuildSphereOptions REGeomBuildSphereDefaultOptions(void);
RE_EXTERN struct REAssetLoadDescriptor * REMeshAssetCreateSphereDescriptor(struct REAssetManager *assetManager, struct REGeomBuildSphereOptions options, bool);

NS_ASSUME_NONNULL_END
