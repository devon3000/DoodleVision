//
//  TestNewSharedSpace.swift
//  DoodleVision
//
//  Created by Huy Le on 11/16/24.
//  Copyright © 2024 Apple. All rights reserved.
//

import SwiftUI
import RealityFoundation
import DoodleVisionAssets
import RealityKit

struct TestNewSharedSpace: View {
    @ObservedObject var viewModel: ContentViewModel

   var body: some View {
       VStack {
           RealityView { content in
               // Add the initial RealityKit content
               if let scene = try? await Entity(named: "Scene", in: doodleVisionAssetsBundle) {
                   content.add(scene)
               }
           } update: { content in
               // Update the RealityKit content when SwiftUI state changes
               if let scene = content.entities.first {
                   let uniformScale: Float = viewModel.enlarged ? 1.4 : 1.0
                   scene.transform.scale = [uniformScale, uniformScale, uniformScale]
               }
           }

           VStack {
               Button(action: viewModel.toggleEnlarge, label: {
                   Text("Ready Start!")
               }).buttonStyle(.bordered).tint(viewModel.enlarged ? .green : .gray)
           }.padding().glassBackgroundEffect()

       }
   }
}

/*
class ContentViewModel: ObservableObject {
    @Published var enlarged = false
    
    func toggleEnlarge() {
        enlarged.toggle()
    }
}
 */

#Preview {
    TestNewSharedSpace(viewModel: ContentViewModel())
}
