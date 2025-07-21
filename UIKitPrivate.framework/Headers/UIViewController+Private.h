#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Private)
- (void)viewDidMoveToWindow:(UIWindow * _Nullable)window shouldAppearOrDisappear:(BOOL)shouldAppearOrDisappear;
@end

NS_ASSUME_NONNULL_END
