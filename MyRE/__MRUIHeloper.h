//
//  __MRUIHeloper.h
//  MyRE
//
//  Created by Jinwoo Kim on 8/1/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface __MRUIHeloper : NSObject
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
+ (NSString *)recursiveDescriptionForWindow:(UIWindow *)window;
+ (NSMapTable<UIWindow *, NSString *> *)recursiveDescriptions;
@end

NS_ASSUME_NONNULL_END
