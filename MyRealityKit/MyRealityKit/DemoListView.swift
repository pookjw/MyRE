//
//  DemoListView.swift
//  MyRealityKit
//
//  Created by Jinwoo Kim on 8/1/25.
//

import SwiftUI

struct DemoListView: View {
    @State private var paths: [Demo] = []
    
    var body: some View {
        NavigationStack(path: $paths) { 
            List(Demo.allCases.reversed()) { demo in
                NavigationLink(String(describing: demo), value: demo)
            }
            .navigationTitle("Miscellaneous")
            .navigationDestination(for: Demo.self) { demo in
                demo.makeView()
            }
        }
        .onAppear { 
            paths = [Demo.defaultCase]
        }
    }
}

extension DemoListView {
    fileprivate enum Demo: Int, CaseIterable, Identifiable, Hashable {
        static let defaultCase: Demo = Demo.allCases.last!
        
        case videoPlayer
        case imagePresentation
        
        var id: Int {
            rawValue
        }
        
        @ViewBuilder
        func makeView() -> some View {
            switch self {
            case .videoPlayer:
                VideoPlayerView()
            case .imagePresentation:
                ImagePresentationView()
            }
        }
    }
}
