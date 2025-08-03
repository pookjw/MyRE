//
//  File.swift
//  MyRE
//
//  Created by Jinwoo Kim on 8/3/25.
//

#if !targetEnvironment(simulator)
import MXI
@preconcurrency import AlchemistService
import Metal
import CoreRE3DGSFoundation

/*
 async function pointer to dispatch thunk of AlchemistService.ALCService.generate(from: __C.CIImage, with: AlchemistService.ALCConfiguration, options: Swift.Optional<Swift.Dictionary<AlchemistService.ALCService.GenerationOption, Any>>) async throws -> __C.MXIScene
 */

@_cdecl("foo")
func foo() {
//    AlchemistService.ALCService.init(mtlDevice: MTLCreateSystemDefaultDevice()!)
//    AlchemistService.ALCConfiguration.init()
    var configuration = AlchemistService.ALCConfiguration()
    configuration.bakingOptions.enableRefinement = true
//    configuration.bakingOptions.type = .scene
    configuration.bakingOptions.set(type: .scene)
//    configuration.sorterOptions.sortingMode = .none
    
    let service = try! AlchemistService.ALCService.init(mtlDevice: MTLCreateSystemDefaultDevice()!, configuration: configuration, eventHandler: { _, _ in
        fatalError()
        return true
    })
    
    Task {
//        let options = [
//            ALCService.GenerationOption.clientName
//        ]
//        let scene = try await service.generate(from: <#T##CGImage#>, with: <#T##ALCConfiguration#>, options: <#T##Optional<Dictionary<ALCService.GenerationOption, Any>>#>)
    }
//    print(AlchemistService.ALCService.self)
}

#endif

/*
 AlchemistService.ALCConfiguration.bakingOptions.modify : AlchemistService.ALCBakingOptions
 AlchemistService.ALCConfiguration.backingOptions.modify : AlchemistService.ALCBakingOptions
 */
