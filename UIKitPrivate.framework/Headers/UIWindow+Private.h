#import <UIKit/UIKit.h>
#import <QuartzCorePrivate/QuartzCorePrivate.h>
#import <CoreRE/Defines.h>
#import <UIKitPrivate/_UIContextBinder.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIWindow (Private) <_UIContextBindable>
@property (readonly, nonatomic) struct UIContextBindingDescription _bindingDescription;
@property (weak, nonatomic, setter=_setBoundContext:) CAContext *_boundContext;
- (struct REEntity * _Nullable)_contextEntity;
- (NSDictionary *)_contextOptionsWithInitialOptions:(NSDictionary *)options;
@end

NS_ASSUME_NONNULL_END
