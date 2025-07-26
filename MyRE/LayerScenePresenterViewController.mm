//
//  LayerScenePresenterViewController.mm
//  MyRE
//
//  Created by Jinwoo Kim on 7/26/25.
//

#import "LayerScenePresenterViewController.h"

@interface LayerScenePresenterViewController ()
@end

@implementation LayerScenePresenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [UIButton new];
    UIButtonConfiguration *configuration = [UIButtonConfiguration plainButtonConfiguration];
    configuration.title = @"Open Scene";
    button.configuration = configuration;
    
    [button addTarget:self action:@selector(_buttonDidTrigger:) forControlEvents:UIControlEventPrimaryActionTriggered];
    self.view = button;
    [button release];
}

- (void)_buttonDidTrigger:(UIButton *)sender {
    UISceneSessionActivationRequest *request = [UISceneSessionActivationRequest requestWithRole:UIWindowSceneSessionRoleApplication];
    NSUserActivity *userActivty = [[NSUserActivity alloc] initWithActivityType:@"LayerScene"];
    request.userActivity = userActivty;
    [userActivty release];
    
    [UIApplication.sharedApplication activateSceneSessionForRequest:request errorHandler:^(NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
}

@end
