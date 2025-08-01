#import <Foundation/Foundation.h>
#import <FrontBoardServices/FBSSceneLayer.h>

NS_ASSUME_NONNULL_BEGIN

@interface FBSScene : NSObject
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (void)attachLayer:(FBSSceneLayer *)layer;
@end

NS_ASSUME_NONNULL_END
