#import <Foundation/Foundation.h>
#import <CoreRE/REDefines.h>

NS_ASSUME_NONNULL_BEGIN

RE_EXTERN struct REComponentClass * REMeshComponentGetComponentType(void);
RE_EXTERN void REMeshComponentSetMesh(struct REComponent *meshComponent, struct REAsset *asset);
RE_EXTERN void REMeshComponentAddMaterial(struct REComponent *meshComponent, struct REAsset *asset);

NS_ASSUME_NONNULL_END
