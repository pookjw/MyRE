//
//  mruiRecursiveDescription.swift
//  MyRealityKit
//
//  Created by Jinwoo Kim on 8/1/25.
//

private import Darwin.POSIX.dlfcn
public import UIKit

/*
 expr -l objc -O -- [(Class)NSClassFromString(@"UIScene") _scenesIncludingInternal:0x1]
 expr -l objc -i0 -O -- [(Class)NSClassFromString(@"MRUIHelper") descriptionForWindow:(id)0x0]
 */

@_objcRuntimeName(__MRUIHeloper)
fileprivate final class MRUIHelper {
    @objc(descriptionForWindow:) class func description(for window: UIWindow) -> String {
        mruiRecursiveDescription(window: window)
    } 
}

public func mruiRecursiveDescription() -> [UIWindow: String] {
    let windows: [UIWindow] = (UIScene.self as AnyClass)
        ._scenesIncludingInternal(ObjCBool(true))
        .compactMap { scene in
            (scene as AnyObject)._allWindows()
        }
        .flatMap { $0 }
    
    var descriptions: [UIWindow: String] = [:]
    descriptions.reserveCapacity(windows.count)
    
    for window in windows {
        let description = mruiRecursiveDescription(window: window)
        descriptions[window] = description
    }
    
    return descriptions
}

public func mruiRecursiveDescription(window: UIWindow) -> String {
    let handle = dlopen("/System/Library/PrivateFrameworks/MRUIKit.framework/MRUIKit", RTLD_NOW)
    let symbol = dlsym(handle, "MRUIEntityViewLayerRecursiveDescription")
    let MRUIEntityViewLayerRecursiveDescription = unsafeBitCast(symbol, to: (@convention(c) (UnsafeRawPointer?, UIView?, CALayer?, NSString, UInt, ObjCBool) -> NSString).self)
    
    let description = MRUIEntityViewLayerRecursiveDescription(
        (window as AnyObject)._contextEntity(),
        window,
        window.layer,
        "-" as NSString,
        0,
        ObjCBool(true)
    ) as String
    
    return description
}

fileprivate final class PrivateSelectors: NSObject {
    @objc(_allWindows) fileprivate func _allWindows() -> [UIWindow] { fatalError() }
    @objc(_contextEntity) fileprivate func _contextEntity() -> UnsafeRawPointer? { fatalError() }
    @objc(_scenesIncludingInternal:) fileprivate class func _scenesIncludingInternal(_ flag: ObjCBool) -> [UIScene] { fatalError() }
}
