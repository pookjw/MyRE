#import <UIKit/UIKit.h>
#import <UIKitPrivate/_UIContextBinder.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIWindowScene (Private)
@property (readonly, nonatomic) _UIContextBinder *_contextBinder;
@end

NS_ASSUME_NONNULL_END
