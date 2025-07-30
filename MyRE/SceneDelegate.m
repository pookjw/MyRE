//
//  SceneDelegate.m
//  MyRE
//
//  Created by Jinwoo Kim on 7/19/25.
//

/*
 RESphereShapeCreate
 */

#import "SceneDelegate.h"
#import "ClassesViewController.h"
#import <MRUIKit/MRUIKit.h>
#import "Utils.h"
#include <objc/runtime.h>

@interface SceneDelegate ()

@end

@implementation SceneDelegate

- (void)dealloc {
    [_window release];
    [super dealloc];
}

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    UIWindow *window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
    ClassesViewController *rootViewController = [[ClassesViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    [rootViewController release];
    window.rootViewController = navigationController;
    [navigationController release];
    self.window = window;
    [window makeKeyAndVisible];
    [window release];
}

@end
