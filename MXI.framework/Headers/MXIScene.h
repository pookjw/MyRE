#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

NS_ASSUME_NONNULL_BEGIN

struct DepthRange {
    float near;
    float far;
};

@interface MXIScene : NSObject
@property (readonly, nonatomic) size_t vertexCount;
@property (readonly, nonatomic) size_t triangleCount;
@property (readonly, nonatomic) size_t opaqueTriangleCount;
@property (readonly, nonatomic) id<MTLBuffer> vertexPositions;
@property (readonly, nonatomic) id<MTLBuffer> vertexUVs;
@property (readonly, nonatomic) id<MTLBuffer> triangleIndices;
@property (readonly, nonatomic) id<MTLBuffer> triangleSliceIndices;
@property (readonly, nonatomic) id<MTLTexture> colorTexture;
@property (readonly, nonatomic) NSArray<id<MTLTexture>> *colorTextures;
@property (nonatomic) long type;
@property (nonatomic) float verticalFOV;
@property (nonatomic) float effectiveVerticalFOV;
@property (nonatomic) float aspectRatio;
@property (nonatomic) unsigned int numLayers;
@property (nonatomic) BOOL isPremultipliedAlpha;
@property (nonatomic) unsigned int resolutionWidth;
@property (nonatomic) unsigned int resolutionHeight;
@property (nonatomic) struct DepthRange depthRange;
@end

NS_ASSUME_NONNULL_END
