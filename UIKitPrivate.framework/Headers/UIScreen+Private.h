#import <UIKit/UIKit.h>
#import <FrontBoardServices/FBSDisplayIdentity.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScreen (Private)
@property (nonatomic, setter=_setClipsToREBounds:) BOOL _clipsToREBounds;
- (FBSDisplayIdentity *)displayIdentity;
@end

NS_ASSUME_NONNULL_END
