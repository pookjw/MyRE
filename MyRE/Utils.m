//
//  Utils.m
//  MyRE
//
//  Created by Jinwoo Kim on 7/22/25.
//

#import "Utils.h"
#import <MRUIKit/MRUIKit.h>

NSString * MR_REEntityGetComponentNames(struct REEntity *entity) {
    NSMutableString *string = [NSMutableString string];
    
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

NSString * MR_REEntityGetRichDebugDescription(struct REEntity *entity) {
    NSMutableString *string = [NSMutableString string];
    
    NSString *description = REEntityGetDebugDescription(entity);
    [string appendString:description];
    
    NSUInteger count = REEntityGetComponentCount(entity);
    if (count > 0) {
        [string appendString:@" ("];
        
        for (NSInteger idx = 0; idx < count; idx++) {
            struct REComponent *component = REEntityGetComponentAtIndex(entity, idx);
            struct REComponentClass *componentClass = REComponentGetClass(component);
            const char *name = REComponentClassGetName(componentClass);
            [string appendFormat:@"%s", name];
            
            if (componentClass == RECALayerClientComponentGetComponentType()) {
                [string appendFormat:@" (size: %@)", NSStringFromCGSize(RECALayerComponentGetLayerSize(component))];
            }
            
            if (idx < (count - 1)) {
                [string appendString:@", "];
            }
        }
        
            [string appendString:@") "];
    }
    
    return string;
}

NSString * _MR_REEntityGetRichDebugDescriptionRecursiveWithIndent(struct REEntity *entity, NSUInteger indent) {
    NSMutableString *string = [NSMutableString string];
    for (NSUInteger c = 0; c < indent; c++) {
        [string appendString:@"-"];
    }
    [string appendString:MR_REEntityGetRichDebugDescription(entity)];
    
    struct REEntity *children[1024];
    unsigned long count = REEntityGetChildren(entity, children, 1024);
    
    for (unsigned long idx = 0; idx < count; idx++) @autoreleasepool {
        [string appendString:@"\n"];
        [string appendString:_MR_REEntityGetRichDebugDescriptionRecursiveWithIndent(children[idx], indent + 2)];
    }
    
    return string;
}

NSString * MR_REEntityGetRichDebugDescriptionRecursive(struct REEntity *entity) {
    return _MR_REEntityGetRichDebugDescriptionRecursiveWithIndent(entity, 0);
}
