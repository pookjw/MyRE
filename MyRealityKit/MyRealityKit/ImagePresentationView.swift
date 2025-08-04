//
//  ImagePresentationView.swift
//  MyRealityKit
//
//  Created by Jinwoo Kim on 8/2/25.
//

import SwiftUI
import RealityKit
import UniformTypeIdentifiers

/*
 REImagePresentationComponentSetStereoImageTextureAsset
 REImagePresentationComponentSetMonoImageTextureAsset
 
 REAssetManagerCreateAssetRequest
 REAssetLoadRequestAddAsset
 
 CGImageSourceCreateWithURL
 RETextureImportOperationCreateFromImageSourceArray
 RETextureImportOperationRun
 RETextureImportOperationCreateAsset
 */

struct ImagePresentationView: View {
    @State private var entity = Entity()
    @State private var component: ImagePresentationComponent?
    
    init() {
        
    }
    
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
            component = try? await ImagePresentationComponent.init(contentsOf: url)
            component?.screenHeight = 0.5
            component?.desiredViewingMode = .spatial3D
        }

    }
}
