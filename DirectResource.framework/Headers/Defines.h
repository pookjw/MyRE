#ifdef __cplusplus
#define DR_EXTERN       extern "C"
#else
#define DR_EXTERN           extern
#endif

#include <simd/simd.h>

DR_EXTERN void DRRetain(void *object);
DR_EXTERN void DRRelease(void *object);

struct DRMeshDescriptor {};
struct DRContext {};
struct DRMesh {};
struct DRBoundingBox {
    simd_float3 min;
    simd_float3 max;
};
