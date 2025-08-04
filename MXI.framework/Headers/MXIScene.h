#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

NS_ASSUME_NONNULL_BEGIN

@interface MXIScene : NSObject
@property (readonly, nonatomic) id<MTLTexture> colorTexture;
@property (readonly, nonatomic) NSArray<id<MTLTexture>> *colorTextures;
@property (nonatomic) float verticalFOV;
@property (nonatomic) float effectiveVerticalFOV;
@property (nonatomic) float aspectRatio;
@property (nonatomic) unsigned int numLayers;
@end

NS_ASSUME_NONNULL_END
