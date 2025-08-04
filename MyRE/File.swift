//
//  File.swift
//  MyRE
//
//  Created by Jinwoo Kim on 8/3/25.
//

#if !targetEnvironment(simulator)
@preconcurrency import MXI
@preconcurrency import AlchemistService
import Metal
import CoreRE3DGSFoundation
@preconcurrency import ImageIO
import UIKit

@_cdecl("mxiSceneFromCIImage")
func mxiSceneFromCIImage(_ ciImage: CIImage, completionHandler: @escaping @Sendable (MXIScene) -> Void) {
    var configuration = AlchemistService.ALCConfiguration()
    configuration.bakingOptions.enableRefinement = true
    configuration.bakingOptions.set(type: .plane)
    
    let service = try! AlchemistService.ALCService.init(mtlDevice: MTLCreateSystemDefaultDevice()!, configuration: configuration, eventHandler: { event, output in
        return true
    })
    
    Task {
        let options: [ALCService.GenerationOption : Any] = [
            ALCService.GenerationOption.clientName: ALCService.ClientName.realityKit,
            ALCService.GenerationOption.focalLengthPx: 24.0,
            ALCService.GenerationOption.adjustmentParams: AdjustmentParams()
        ]
        
        let scene = try! await service.generate(from: ciImage, with: configuration, options: options)
        completionHandler(scene)
    }
}

#endif
