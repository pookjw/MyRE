//
//  ClassesViewController.m
//  MyRE
//
//  Created by Jinwoo Kim on 7/21/25.
//

#import "ClassesViewController.h"
#import "BasicViewController.h"
#import "CALayerViewController.h"
#import "LayerScenePresenterViewController.h"
#import "VideoPlayerViewController.h"
#import "VideoRendererViewController.h"
#import "ImagePresentationViewController.h"
#import "Spatial3DImageViewController.h"

@interface ClassesViewController ()
@property (class, nonatomic, readonly, getter=_classes) NSArray<Class> *classes;
@property (retain, nonatomic, readonly, getter=_cellRegistration) UICollectionViewCellRegistration *cellRegistration;
@end

@implementation ClassesViewController
@synthesize cellRegistration = _cellRegistration;

+ (NSArray<Class> *)_classes {
    return @[
        [Spatial3DImageViewController class],
        [ImagePresentationViewController class],
        [VideoRendererViewController class],
        [VideoPlayerViewController class],
        [LayerScenePresenterViewController class],
        [CALayerViewController class],
        [BasicViewController class]
    ];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    UICollectionLayoutListConfiguration *listConfiguration = [[UICollectionLayoutListConfiguration alloc] initWithAppearance:UICollectionLayoutListAppearanceInsetGrouped];
    UICollectionViewCompositionalLayout *collectionViewLayout = [UICollectionViewCompositionalLayout layoutWithListConfiguration:listConfiguration];
    [listConfiguration release];
    
    if (self = [super initWithCollectionViewLayout:collectionViewLayout]) {
        _cellRegistration = [[UICollectionViewCellRegistration registrationWithCellClass:[UICollectionViewListCell class] configurationHandler:^(UICollectionViewListCell * _Nonnull cell, NSIndexPath * _Nonnull indexPath, Class _Nonnull _class) {
            UIListContentConfiguration *contentConfiguration = [cell defaultContentConfiguration];
            contentConfiguration.text = NSStringFromClass(_class);
            cell.contentConfiguration = contentConfiguration;
        }] retain];
    }
    
    return self;;
}

- (void)dealloc {
    [_cellRegistration release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    Class _class = ClassesViewController.classes.firstObject;
    Class _class = [ImagePresentationViewController class];
    __kindof UIViewController *viewController = [[_class alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return ClassesViewController.classes.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [collectionView dequeueConfiguredReusableCellWithRegistration:self.cellRegistration forIndexPath:indexPath item:ClassesViewController.classes[indexPath.item]];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Class _class = ClassesViewController.classes[indexPath.item];
    __kindof UIViewController *viewController = [[_class alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
}

@end
