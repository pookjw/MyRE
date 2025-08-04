//
//  Spatial3DImageView.swift
//  MyRealityKit
//
//  Created by Jinwoo Kim on 8/3/25.
//

import SwiftUI
import RealityKit
import UniformTypeIdentifiers

struct Spatial3DImageView: View {
    @State private var component: ImagePresentationComponent?
    @State private var entity: Entity = .init()
    
    var body: some View {
        RealityView { content in
            content.add(entity)
            entity.transform.scale = .init(x: 0.5, y: 0.5, z: 0.5)
        } update: { content in
            if let component {
                entity.components.set(component)
            }
        }
        .task {
            let url = Bundle.main.url(forResource: "spatial_image", withExtension: UTType.heic.preferredFilenameExtension)!
            let spatial3DImage = try! await ImagePresentationComponent.Spatial3DImage(contentsOf: url)
            try! await spatial3DImage.generate()
            
            for child in Mirror(reflecting: spatial3DImage).children {
                print(child)
            }
            
            print("---")
            
            let mxiSceneResource = Mirror(reflecting: spatial3DImage).descendant("mxiSceneResource")!
            let someValue = Mirror(reflecting: mxiSceneResource).descendant("some")!
            for child in Mirror(reflecting: someValue).children {
                print(child)
            }
            
            component = ImagePresentationComponent(spatial3DImage: spatial3DImage)
            component!.desiredViewingMode = .spatial3D
        }
    }
}

/*
 MXISceneBuilderTiled
 -[MXISceneBuilder initWithType:numberOfLayers:depthRange:options:]
 -[MXISceneBuilder buildSceneWithOptions error:]
 MXIScene - (id) initWithPosition:(const void*)arg1 uvs:(const void*)arg2 triangles:(const void*)arg3 slices:(const void*)arg4 colorTextures:(id)arg5 colorTexture:(id)arg6 colorTextureSlices:(unsigned int)arg7 normalTexture:(id)arg8 pbrTextures:(id)arg9 pbrMaterialDescriptor:(id)arg10 iblFileName:(id)arg11;
 */

/*
 0x1117b0200 (MXIScene)
 */
