#import <UIKit/UIKit.h>
#import <CoreRE/Defines.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Private)
@property (nonatomic, setter=_setClipsToREBounds:) _Bool _clipsToREBounds;
- (void)_requestSeparatedState:(NSInteger)state withReason:(NSString *)reason;
+ (struct REEntity * _Nullable)_reEntity;
@end

NS_ASSUME_NONNULL_END
