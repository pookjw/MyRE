#import <UIKit/UIKit.h>
#import <QuartzCorePrivate/QuartzCorePrivate.h>
#import <CoreRE/Defines.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIWindow (Private)
@property (weak, nonatomic, setter=_setBoundContext:) CAContext *_boundContext;
- (struct REEntity * _Nullable)_contextEntity;
@end

NS_ASSUME_NONNULL_END
