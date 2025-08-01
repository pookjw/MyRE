#import <Foundation/Foundation.h>
#import <QuartzCorePrivate/CAContext.h>

NS_ASSUME_NONNULL_BEGIN

@interface FBSSceneLayer : NSObject
@property (nonatomic, readonly) CAContext *CAContext;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
