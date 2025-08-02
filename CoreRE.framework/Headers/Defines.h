#ifdef __cplusplus
#define RE_EXTERN       extern "C"
#else
#define RE_EXTERN           extern
#endif

struct REEntity {};

struct REComponentClass {};

struct REComponent {};

struct RECollisionMeshShape {};

struct RECollisionMesh {};

struct REMesh {};

struct RECollisionShape {};

struct REAsset {};

struct REEngine {};

struct REAssetManager {};

struct REServiceLocator {};

struct REAssetHandle {};

struct REAssetLoadDescriptor {};

struct REGeomBuildSphereOptions {
    unsigned int value0;
    float radius;
    unsigned int value1;
};

struct REMaterialParameter {};

struct REColorGamut4F {
    float r, g, b, a;
};

struct REScene {};

struct RECALayerService {};

struct RETransformService {};

struct RETextureImportOperation {};

struct REAssetLoadRequest {};

struct RESpatial3DImage {};
