//
//  __MRUIHeloper.m
//  MyRE
//
//  Created by Jinwoo Kim on 8/1/25.
//

#import "__MRUIHeloper.h"
#import <UIKitPrivate/UIKitPrivate.h>
#import <MRUIKit/MRUIKit.h>

@implementation __MRUIHeloper

+ (NSString *)recursiveDescriptionForWindow:(UIWindow *)window {
    return MRUIEntityViewLayerRecursiveDescription([window _contextEntity], window, window.layer, @"-", 0, YES);
}

+ (NSMapTable<UIWindow *,NSString *> *)recursiveDescriptions {
    NSArray<UIScene *> *scenes = [UIScene _scenesIncludingInternal:YES];
    NSMutableArray<UIWindow *> *windows = [[NSMutableArray alloc] init];
    for (UIScene *scene in scenes) {
        [windows addObjectsFromArray:[scene _allWindows]];
    }
    
    NSMapTable<UIWindow *, NSString *> *descriptions = [NSMapTable strongToStrongObjectsMapTable];
    for (UIWindow *window in windows) {
        [descriptions setObject:[__MRUIHeloper recursiveDescriptionForWindow:window] forKey:window];
    }
    [windows release];
    
    return descriptions;
}

@end
