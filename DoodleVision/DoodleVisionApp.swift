/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The app structure.
*/

import SwiftUI
import RealityKit

/// The structure of the DoodleVision app: a main window and a Full Space for gameplay.
@main
struct DoodleVisionApp: App {
    @State private var gameModel = GameModel()
    @State private var immersionState: ImmersionStyle = .mixed
    @State private var fullAppState = FullAppState()
    
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        
    }
    
    var body: some SwiftUI.Scene {
        
        WindowGroup("DoodleVision", id: "doodleVisionApp") {
            ContentView(viewModel: fullAppState.contentViewModel)
                .environment(fullAppState)
        }
        .windowStyle(.plain)
        .onChange(of: scenePhase) { _, newScenePhase in
            Task {
                if newScenePhase == .active {
                    await openImmersiveSpace(id: "ImmersiveSpace")
                }
            }
            
            ImmersiveSpace(id: "PaintingScene") {
                DoodleVisionSpace(gestureModel: HeartGestureModelContainer.heartGestureModel)
                    .environment(gameModel)
                    .environment(fullAppState)
            }
            .immersionStyle(selection: $immersionState, in: .mixed)
            
            /*
             WindowGroup("DoodleVision", id: "doodleVisionApp") {
             Intro()
             .onAppear {
             guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
             return
             }
             
             windowScene.requestGeometryUpdate(.Vision(resizingRestrictions: UIWindowScene.ResizingRestrictions.none))
             }
             }
             .windowStyle(.plain)
             
             ImmersiveSpace(id: "doodleVision") {
             
             TestNewSharedSpace(viewModel: newContentViewModel)
             
             /*
              DoodleVisionSpace(gestureModel: HeartGestureModelContainer.heartGestureModel)
              .environment(gameModel)
              */
             }
             .immersionStyle(selection: $immersionState, in: .mixed)
             */
        }
        
        /*
         var body: some SwiftUI.Scene {
         WindowGroup("DoodleVision", id: "doodleVisionApp") {
         DoodleVision()
         .environment(gameModel)
         .onAppear {
         guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
         return
         }
         
         windowScene.requestGeometryUpdate(.Vision(resizingRestrictions: UIWindowScene.ResizingRestrictions.none))
         }
         }
         .windowStyle(.plain)
         
         ImmersiveSpace(id: "doodleVision") {
         DoodleVisionSpace(gestureModel: HeartGestureModelContainer.heartGestureModel)
         .environment(gameModel)
         }
         .immersionStyle(selection: $immersionState, in: .mixed)
         }
         */
    }
}

@MainActor
enum HeartGestureModelContainer {
    private(set) static var heartGestureModel = HeartGestureModel()
}
