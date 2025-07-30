#import <Foundation/Foundation.h>
#import <FrontBoardServices/FBSScene.h>
#import <QuartzCorePrivate/CAContext.h>
#import <UIKitPrivate/_UIContextBinder.h>

NS_ASSUME_NONNULL_BEGIN

@interface _UIContextBinderSubstrate : NSObject <_UIContextBinding>
@property (readonly, nonatomic) FBSScene* scene;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithScene:(FBSScene *)scene NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
