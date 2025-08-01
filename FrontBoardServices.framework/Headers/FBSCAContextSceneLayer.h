#import <FrontBoardServices/FBSSceneLayer.h>

NS_ASSUME_NONNULL_BEGIN

@interface FBSCAContextSceneLayer : FBSSceneLayer
+ (FBSCAContextSceneLayer *)layerWithCAContext:(CAContext *)context;
- (instancetype)initWithCAContext:(CAContext *)context;
@end

NS_ASSUME_NONNULL_END
