//
//  Utils.h
//  MyRE
//
//  Created by Jinwoo Kim on 7/22/25.
//

#import <CoreRE/CoreRE.h>

NS_ASSUME_NONNULL_BEGIN

RE_EXTERN NSString * MR_REEntityGetComponentNames(struct REEntity *entity);
RE_EXTERN NSString * MR_REEntityGetRichDebugDescription(struct REEntity *entity);
RE_EXTERN NSString * MR_REEntityGetRichDebugDescriptionRecursive(struct REEntity *entity);

NS_ASSUME_NONNULL_END
