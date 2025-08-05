#import <Foundation/Foundation.h>
#import <DirectResource/Defines.h>

NS_ASSUME_NONNULL_BEGIN

DR_EXTERN void DRMeshUpdateVertices(struct DRMesh *mesh, unsigned long index, void (^block)(void *bytes, long long length));
DR_EXTERN void DRMeshUpdateIndices(struct DRMesh *mesh, void (^block)(void *bytes, long long length));
DR_EXTERN unsigned long DRMeshGetPartCount(struct DRMesh *mesh);
DR_EXTERN void DRMeshSetPartCount(struct DRMesh *mesh, unsigned long count);
DR_EXTERN void DRMeshSetPartAt(struct DRMesh *mesh, unsigned long index, unsigned long, unsigned long, unsigned int, unsigned long);

NS_ASSUME_NONNULL_END
