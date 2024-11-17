/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The app structure.
*/

import SwiftUI
import RealityKit

/// The structure of the Happy Beam app: a main window and a Full Space for gameplay.
@main
struct DoodleVisionApp: App {
    // @State private var gameModel = GameModel()
    // @State private var immersionState: ImmersionStyle = .mixed
    // private var newContentViewModel = ContentViewModel()
    
    init() {
        
    }
    
    var body: some SwiftUI.Scene {
        
        WindowGroup("DoodleVision", id: "doodleVisionApp") {
            ContentView(viewModel: ContentViewModel())
        }
        .windowStyle(.plain)
            
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

@MainActor
enum HeartGestureModelContainer {
    private(set) static var heartGestureModel = HeartGestureModel()
}
