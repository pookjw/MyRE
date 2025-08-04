//
//  AppDelegate.m
//  MyRE
//
//  Created by Jinwoo Kim on 7/19/25.
//

#import "AppDelegate.h"
#import "SceneDelegate.h"
#import "LayerSceneDelegate.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    NSString * _Nullable activityType = options.userActivities.allObjects.firstObject.activityType;
    UISceneConfiguration *configuration = [connectingSceneSession.configuration copy];
    
    if ([activityType isEqualToString:@"LayerScene"]) {
        configuration.delegateClass = [LayerSceneDelegate class];
    } else {
        configuration.delegateClass = [SceneDelegate class];
    }
    
    return [configuration autorelease];
}

@end
