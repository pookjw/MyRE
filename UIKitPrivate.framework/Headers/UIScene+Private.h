#import <UIKit/UIKit.h>
#import <FrontBoardServices/FBSScene.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScene (Private)
+ (NSArray<UIScene *> *)_scenesIncludingInternal:(BOOL)includeInternal;
@property (nonatomic, readonly, getter=_FBSScene) FBSScene *_FBSScene;
- (UIScene * _Nullable)_windowHostingScene;
- (NSArray<UIWindow *> *)_allWindows;
@end

NS_ASSUME_NONNULL_END
