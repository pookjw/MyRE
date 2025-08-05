#import <Foundation/Foundation.h>
#import <DirectResource/Defines.h>
#import <Metal/Metal.h>

NS_ASSUME_NONNULL_BEGIN

DR_EXTERN struct DRMeshDescriptor * DRMeshDescriptorCreate(void);
DR_EXTERN void DRMeshDescriptorSetIndexCapacity(struct DRMeshDescriptor *descriptor, size_t capacity);
DR_EXTERN void DRMeshDescriptorSetIndexType(struct DRMeshDescriptor *descriptor, unsigned long indexType);
DR_EXTERN void DRMeshDescriptorSetVertexCapacity(struct DRMeshDescriptor *descriptor, size_t capacity);
DR_EXTERN void DRMeshDescriptorSetVertexBufferCount(struct DRMeshDescriptor *descriptor, size_t count);
DR_EXTERN void DRMeshDescriptorSetVertexAttributeCount(struct DRMeshDescriptor *descriptor, size_t count);
DR_EXTERN void DRMeshDescriptorSetVertexLayoutCount(struct DRMeshDescriptor *descriptor, size_t count);
DR_EXTERN void DRMeshDescriptorSetVertexAttributeFormat(struct DRMeshDescriptor *descriptor, size_t index, unsigned int, MTLVertexFormat, unsigned long, unsigned long);
DR_EXTERN void DRMeshDescriptorSetVertexLayout(struct DRMeshDescriptor *descriptor, size_t index, unsigned long, unsigned long, unsigned long);

NS_ASSUME_NONNULL_END
