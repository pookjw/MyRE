#import <UIKit/UIKit.h>
#import <CoreRE/REEntity.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIWindow (MRUI)
- (struct REEntity *)reEntity;
- (BOOL)_mrui_wantsLayerComponentRespectsLayerTransform;
- (CGFloat)mrui_pointsPerMeter;
@end

NS_ASSUME_NONNULL_END
