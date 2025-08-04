//
//  Spatial3DImageViewController.m
//  MyRE
//
//  Created by Jinwoo Kim on 8/3/25.
//

#import "Spatial3DImageViewController.h"
#import "MyRE-Swift.h"
#import <CoreRE/CoreRE.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKitPrivate/UIKitPrivate.h>
#import <MRUIKit/MRUIKit.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
#include <TargetConditionals.h>

@interface Spatial3DImageViewController ()

@end

@implementation Spatial3DImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
#if !TARGET_OS_SIMULATOR
    NSURL *url = [NSBundle.mainBundle URLForResource:@"spatial_image_1" withExtension:UTTypeHEIC.preferredFilenameExtension];
    assert(url != nil);
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)url, NULL);
    size_t count = CGImageSourceGetCount(imageSource);
    if (count > 0) {
        NSDictionary *properties = (id)CGImageSourceCopyProperties(imageSource, NULL);
        NSArray<NSDictionary *> *groups = [properties objectForKey:(id)kCGImagePropertyGroups];
        
        NSDictionary *stereoPairGroup = nil;
        for (NSDictionary *group in groups) {
            NSString *groupType = [group objectForKey:(id)kCGImagePropertyGroupType];
            if ([groupType isEqual:(id)kCGImagePropertyGroupTypeStereoPair]) {
                stereoPairGroup = group;
                break;
            }
        }
        
        unsigned int monoscopicImageIndex = ((NSNumber *)[stereoPairGroup objectForKey:(id)kCGImagePropertyGroupImageIndexMonoscopic]).unsignedIntValue;
        CGImageRef cgImage = CGImageSourceCreateImageAtIndex(imageSource, monoscopicImageIndex, (CFDictionaryRef)@{
            (id)kCGImageSourceDecodeRequest: (id)kCGImageSourceDecodeToSDR,
            @"kCGImageSourceShouldUseRawDataForFullSize": @YES
        });
        CIImage *ciImage = [[CIImage alloc] initWithCGImage:cgImage];
        mxiSceneFromCIImage(ciImage, ^(MXIScene * _Nonnull scene) {
            NSLog(@"%@", scene); 
        });
    }
#endif
}

@end

/*
 (label: Optional("meshInternal"), value: 0x0000000110f2d318) -> REImagePresentationComponentSetMXIMeshAsset
 */
