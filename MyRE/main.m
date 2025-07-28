//
//  main.m
//  MyRE
//
//  Created by Jinwoo Kim on 7/19/25.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        [NSUserDefaults.standardUserDefaults setBool:YES forKey:@"com.apple.re.EnableCARETransformLogging"];
        [NSUserDefaults.standardUserDefaults setBool:YES forKey:@"com.apple.re.EnableTransformServiceVisitationLogging"];
        [NSUserDefaults.standardUserDefaults setBool:YES forKey:@"EnableTransformServiceVisitationLogging"];
        [NSUserDefaults.standardUserDefaults setBool:NO forKey:@"com.apple.re.EnableTransformServiceCache"];
        [NSUserDefaults.standardUserDefaults setBool:NO forKey:@"EnableTransformServiceCache"];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
