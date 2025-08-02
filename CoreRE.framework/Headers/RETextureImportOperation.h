#import <Foundation/Foundation.h>
#import <CoreRE/Defines.h>
#import <ImageIO/ImageIO.h>
#import <Metal/Metal.h>

NS_ASSUME_NONNULL_BEGIN

RE_EXTERN struct RETextureImportOperation * RETextureImportOperationCreateFromImageSourceArray(NSArray<id> *imageSources, const unsigned int *indexes, struct REServiceLocator *serviceLocater, MTLTextureType textureType, NSError * __autoreleasing _Nullable * _Nullable error);
RE_EXTERN BOOL RETextureImportOperationRun(struct RETextureImportOperation *operation, NSError * __autoreleasing _Nullable * _Nullable error);
RE_EXTERN void RETextureImportOperationSetSemantic(struct RETextureImportOperation *operation, unsigned int semantic);
RE_EXTERN void RETextureImportOperationSetMipmapMode(struct RETextureImportOperation *operation, unsigned int mipmapMode);
RE_EXTERN void RETextureImportOperationSetCompressionType(struct RETextureImportOperation *operation, unsigned int compressionType);
RE_EXTERN void RETextureImportOperationSetReduceMemoryPeak(struct RETextureImportOperation *operation, BOOL reduceMemoryPeak);
RE_EXTERN struct REAsset * _Nullable RETextureImportOperationCreateAsset(struct RETextureImportOperation *operation, BOOL flag, NSError * __autoreleasing _Nullable * _Nullable error);

NS_ASSUME_NONNULL_END
