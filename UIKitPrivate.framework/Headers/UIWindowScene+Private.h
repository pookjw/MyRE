#import <UIKit/UIKit.h>
#import <UIKitPrivate/_UIContextBinder.h>
#import <CoreRE/CoreRE.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIWindowScene (Private)
@property (readonly, nonatomic) _UIContextBinder *_contextBinder;
@property (readonly, nonatomic) struct REScene *reScene;
@property (nonatomic, readonly) struct CGRect bounds;
@end

NS_ASSUME_NONNULL_END
