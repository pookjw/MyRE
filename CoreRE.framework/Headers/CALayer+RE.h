#import <QuartzCore/QuartzCore.h>
#import <CoreRE/REEntity.h>

NS_ASSUME_NONNULL_BEGIN

@interface CALayer (RE)
- (struct REEntity * _Nullable)_careEntity;
- (void)_careSeparate:(BOOL)flag;
@end

NS_ASSUME_NONNULL_END