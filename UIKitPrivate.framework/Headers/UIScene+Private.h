#import <UIKit/UIKit.h>
#import <FrontBoardServices/FBSScene.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScene (Private)
@property (nonatomic, readonly, getter=_FBSScene) FBSScene *_FBSScene;
- (UIScene * _Nullable)_windowHostingScene;
@end

NS_ASSUME_NONNULL_END
