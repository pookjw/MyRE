#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScreen (Private)
@property (nonatomic, setter=_setClipsToREBounds:) _Bool _clipsToREBounds;
- (id)displayIdentity;
@end

NS_ASSUME_NONNULL_END
