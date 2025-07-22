//
//  CALayerViewController.m
//  MyRE
//
//  Created by Jinwoo Kim on 7/22/25.
//

#import "CALayerViewController.h"
#import <CoreRE/CoreRE.h>
#import <MRUIKit/MRUIKit.h>
#import <UIKitPrivate/UIKitPrivate.h>
#import "Utils.h"

@interface MyLayer : CALayer
@end
@implementation MyLayer
- (void)drawInContext:(CGContextRef)ctx {
    [super drawInContext:ctx];
}
@end

@interface MyView : UIView
@end
@implementation MyView
+ (Class)layerClass {
    return [MyLayer class];
}
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}
@end

@interface CALayerViewController ()

@end

@implementation CALayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
}

- (void)viewDidMoveToWindow:(UIWindow *)window shouldAppearOrDisappear:(BOOL)shouldAppearOrDisappear {
    [super viewDidMoveToWindow:window shouldAppearOrDisappear:shouldAppearOrDisappear];
    
    if (window) {
        MyView *subview = [[MyView alloc] init];
        subview.frame = CGRectMake(0., 0., 300., 300.);
        subview.layer.backgroundColor = UIColor.redColor.CGColor;
//        [sublayer _careSeparate:YES];
//        struct REEntity *subentity = [sublayer _careEntity];
//        REEntitySetName(subentity, "My Layer Entity");
        
        [subview _requestSeparatedState:1 withReason:@"_UIViewSeparatedStateRequestReasonUnspecified"];
        struct REEntity *entity = [window reEntity];
        struct REEntity *subentity = [subview _reEntity];
        REEntitySetName(subentity, "My Layer Entity");
        REEntityInsertChild(entity, subentity, 0);
    //    [sublayer release];
        
        NSLog(@"%@", MR_REEntityGetRichDebugDescriptionRecursive([self.view.window reEntity]));
        [subview setNeedsDisplay];
        [subview.layer setNeedsDisplay];
    }
}

@end
