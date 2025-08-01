//
//  VideoPlayerView.swift
//  MyRealityKit
//
//  Created by Jinwoo Kim on 8/1/25.
//

import SwiftUI
import RealityKit
import AVFoundation

public struct VideoPlayerView: View {
    @State private var player = AVPlayer(url: Bundle.main.url(forResource: "video", withExtension: "mp4")!)
    
    public var body: some View {
        RealityView { content in
            let entity = Entity()
            var videoPlayerComponent = VideoPlayerComponent(avPlayer: player)
            entity.components.set(videoPlayerComponent)
            entity.scale *= 0.4
            content.add(entity)
        }
    }
}
