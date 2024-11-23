//
//  ContentView.swift
//  DoodleVision
//
//  Created by Huy Le on 11/16/24.
//  Copyright © 2024 Apple. All rights reserved.
//

import SwiftUI
import RealityFoundation
import DoodleVisionAssets
import RealityKit
import GroupActivities
import Combine

struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel
    
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    
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
            .task {
                viewModel.configureGroupSession()
            }
            .task {
                viewModel.registerGroupActivity()
            }
            .onAppear {
                Task {
                    await openImmersiveSpace(id: "PaintingScene")
                }
            }
            
            VStack {
                Button(action: viewModel.toggleEnlarge, label: {
                    Text("Enlarge Sphere")
                }).buttonStyle(.bordered).tint(viewModel.enlarged ? .green : .gray)
                Button(action: viewModel.toggleSharePlay, label: {
                    Text("SharePlay")
                }).buttonStyle(.bordered).tint(viewModel.sharePlayEnabled ? .green : .gray)
            }.padding().glassBackgroundEffect()
            
            
        }
    }
}

class ContentViewModel: ObservableObject {
    @Published var enlarged = false
    @Published var sharePlayEnabled = false
    var tasks = Set<Task<Void, Never>>()
    var subscriptions: Set<AnyCancellable> = []
    var sharePlayMessenger: GroupSessionMessenger?
    var sharePlaySession: GroupSession<PlayTogetherGroupActivity>?
    
    var fullAppState: FullAppState?
    
    func toggleEnlarge() {
        enlarged.toggle()
        sendEnlargeMessage(EnlargeMessage(enlarged: enlarged))
    }
    
    func addNetworkedPointAtPos(_ newPose: Pose3D) {
        
        var addPointMessage = AddPointMessage(pose: newPose)
        
        Task {
            do {
                try await sharePlayMessenger?.send(addPointMessage)
            } catch {
                print("addPointMessage failed \(error)")
            }
        }
    }
    
    func finishStroke() {
        var finishStrokeMessage = FinishStrokeMessage()
        
        Task {
            do {
                try await sharePlayMessenger?.send(finishStrokeMessage)
            } catch {
                print("addPointMessage failed \(error)")
            }
        }
    }
    
    func sendEnlargeMessage(_ message: EnlargeMessage) {
        Task {
            do {
                try await sharePlayMessenger?.send(message)
            } catch {
                print("sendEnlargeMessage failed \(error)")
            }
        }
    }
        
    func toggleSharePlay() {
        if (!self.sharePlayEnabled) {
            startSharePlay()
        } else {
            endSharePlay()
        }
    }
    
    func startSharePlay() {
        Task {
            let activity = PlayTogetherGroupActivity()
            switch await activity.prepareForActivation() {
            case .activationPreferred:
                do {
                    _ = try await activity.activate()
                } catch {
                    print("SharePlay unable to activate the activity: \(error)")
                }
            case .activationDisabled:
                print("SharePlay group activity activation disabled")
            case .cancelled:
                print("SharePlay group activity activation cancelled")
            @unknown default:
                print("SharePlay group activity activation unknown case")
            }
        }
    }
    
    func endSharePlay() {
        self.sharePlaySession?.end()
    }
    
    func configureGroupSession() {
        Task {
            for await session in PlayTogetherGroupActivity.sessions() {
                self.sharePlaySession = session
                let messenger = GroupSessionMessenger(session: session)
                self.sharePlayMessenger = messenger
                
                self.tasks.insert(
                    Task {
                        for await (message, _) in messenger.messages(of: EnlargeMessage.self) {
                            handle(message)
                        }
                    }
                )
                
                self.tasks.insert(
                    Task {
                        // Add Point
                        for await (message, _) in messenger.messages(of: AddPointMessage.self) {
                            handleAddPointMessage(message)
                        }
                    }
                )
                
                self.tasks.insert(
                    Task {
                        // Finish Stroke
                        for await (message, _) in messenger.messages(of: FinishStrokeMessage.self) {
                            handleFinishStrokeMessage(message)
                        }
                    }
                )
                
                session.$activeParticipants
                    .sink {
                        let newParticipants = $0.subtracting(session.activeParticipants)
                        Task { @MainActor in
                            try? await messenger.send(EnlargeMessage(enlarged: self.enlarged),
                                                      to: .only(newParticipants))
                        }
                    }
                    .store(in: &self.subscriptions)
                
                session.$state
                    .sink {
                        if case .invalidated = $0 {
                            self.sharePlayMessenger = nil
                            self.tasks.forEach { $0.cancel() }
                            self.tasks = []
                            self.subscriptions = []
                            self.sharePlaySession = nil
                            self.sharePlayEnabled = false
                        }
                    }
                    .store(in: &self.subscriptions)
#if os(visionOS)
                 if let systemCoordinator = await session.systemCoordinator {
                     var configuration = SystemCoordinator.Configuration()
                     configuration.supportsGroupImmersiveSpace = true
                     configuration.spatialTemplatePreference = .conversational
                     systemCoordinator.configuration = configuration
                     
                     self.tasks.insert(
                        Task.detached { @MainActor in
                            for await immersionStyle in systemCoordinator.groupImmersionStyle {
                                if let immersionStyle {
                                 // await openImmersiveSpace(id: "PaintingScene")
                                } else {
//                                 await dismissImmersiveSpace()
                                }
                            }
                        }
                    )
                 }
#endif
                
                Task {
                    @MainActor in
                    sharePlayEnabled = true
                }
                
                session.join()
            }
        }
    }
    
    func handle(_ message: EnlargeMessage) {
        Task {
            @MainActor in
            self.enlarged = message.enlarged
        }
    }
    
    func handleAddPointMessage(_ message: AddPointMessage) {
        Task {
            @MainActor in
            
            var transformPoint = Transform(matrix: simd_float4x4(message.pose))
            
            print("Try handle add point message.")
            fullAppState?.canvas.addPoint(transformPoint.translation)
        }
    }
    
    func handleFinishStrokeMessage(_ message: FinishStrokeMessage) {
        Task {
            @MainActor in
            
            print("Try handle finish stroke message.")
            fullAppState?.canvas.finishStroke()
        }
    }
    
    func registerGroupActivity() {
        let itemProvider = NSItemProvider()
        itemProvider.registerGroupActivity(PlayTogetherGroupActivity())
        let configuration = UIActivityItemsConfiguration(itemProviders: [itemProvider])
        configuration.metadataProvider = { key in
            guard key == .linkPresentationMetadata else { return Void.self }
            let metadata = PlayTogetherGroupActivity().metadata
            return metadata
        }
        UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?
            .windows
            .first?
            .rootViewController?
            .activityItemsConfiguration = configuration
    }
}

#Preview {
    ContentView(viewModel: ContentViewModel())
}
