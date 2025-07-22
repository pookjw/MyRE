//
//  Utils.m
//  MyRE
//
//  Created by Jinwoo Kim on 7/22/25.
//

#import "Utils.h"

NSString * MR_REEntityCopyComponentNames(struct REEntity *entity) {
    NSMutableString *string = [[NSMutableString alloc] init];
    
    NSUInteger count = REEntityGetComponentCount(entity);
    for (NSInteger idx = 0; idx < count; idx++) {
        struct REComponent *component = REEntityGetComponentAtIndex(entity, idx);
        struct REComponentClass *componentClass = REComponentGetClass(component);
        const char *name = REComponentClassGetName(componentClass);
        [string appendFormat:@"%s", name];
        if (idx < (count - 1)) {
            [string appendString:@", "];
        }
    }
    
    return string;
}
