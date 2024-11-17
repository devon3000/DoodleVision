/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The space where the game takes place.
*/

import Accelerate
import AVKit
import Combine
import GameController
import RealityKit
import SwiftUI
import DoodleVisionAssets
import ARKit

/// The Full Space that displays when someone plays the game.
struct DoodleVisionSpace: View {
    
    @Environment(FullAppState.self) private var fullAppState
    
    @ObservedObject var gestureModel: HeartGestureModel
    @Environment(GameModel.self) var gameModel
    
    @State private var emittingBeam = false
    @State private var blasterPosition = Float(0)
    @State private var lastGestureUpdateTime: TimeInterval = 0
    @State private var draggedEntity: Entity? = nil
    @State private var positions: [SIMD3<Float>] = []
    @State private var orientations: [simd_quatf] = []
    @State private var collisionSubscription: EventSubscription?
    @State private var activationSubscription: EventSubscription?
    
    /// The instance of the `PaintingCanvas` class to handle painting operation.
    // @State var canvas = PaintingCanvas()

    /// The position of the index finger on the last pinch gesture.
    @State var lastIndexPose: SIMD3<Float>?
    
    var collisionEntity = Entity()
    
    var body: some View {
        RealityView { content in
//            // The root entity.
//            content.add(spaceOrigin)
//            content.add(cameraRelativeAnchor)
//            spaceOrigin.addChild(beamIntermediate)
//            
//            // MARK: Events
//            activationSubscription = content.subscribe(to: AccessibilityEvents.Activate.self, on: nil, componentType: nil) { activation in
//                Task {
//                    try handleCloudHit(for: activation.entity, gameModel: gameModel)
//                }
//            }
//            
//            collisionSubscription = content.subscribe(to: CollisionEvents.Began.self, on: nil, componentType: nil) { event in
//                Task {
//                    try await handleCollisionStart(for: event, gameModel: gameModel)
//                }
//            }
//            
//            Task.detached {
//                for await _ in NotificationCenter.default.notifications(named: .GCControllerDidConnect) {
//                    Task { @MainActor in
//                        for controller in GCController.controllers() {
//                            controller.extendedGamepad?.valueChangedHandler = { pad, _ in
//                                Task { @MainActor in
//                                    if gameModel.isUsingControllerInput == false {
//                                        gameModel.isUsingControllerInput = true
//                                    }
//                                    gameModel.controllerInputX = pad.leftThumbstick.xAxis.value
//                                    gameModel.controllerInputY = pad.leftThumbstick.yAxis.value
//                                    if gameModel.controllerInputX != 0, gameModel.controllerInputY != 0 {
//                                        gameModel.controllerLastInput = Date.timeIntervalSinceReferenceDate
//                                    }
//                                }
//                            }
//                            
//                            if controller.extendedGamepad == nil {
//                                controller.microGamepad?.valueChangedHandler = { pad, _ in
//                                    Task { @MainActor in
//                                        if gameModel.isUsingControllerInput == false {
//                                            gameModel.isUsingControllerInput = true
//                                        }
//                                        gameModel.controllerInputX = pad.dpad.xAxis.value
//                                        gameModel.controllerInputY = pad.dpad.yAxis.value
//                                        if gameModel.controllerInputX != 0, gameModel.controllerInputY != 0 {
//                                            gameModel.controllerLastInput = Date.timeIntervalSinceReferenceDate
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
            
            
            let root = fullAppState.canvas.root

            // Add the canvas to the reality view.
            content.add(root)

            // Attach a closure component to allow hand anchors to update over time.
            root.components.set(ClosureComponent(closure: { deltaTime in
                /// The collection of `HandAnchor` instances.
                var anchors = [HandAnchor]()

                // Add the left hand to the anchors collection.
                if let latestLeftHand = gestureModel.latestHandTracking.left {
                    anchors.append(latestLeftHand)
                }

                // Add the right hand to the anchors collection.
                if let latestRightHand = gestureModel.latestHandTracking.right {
                    anchors.append(latestRightHand)
                }

                // Loop through each anchor the app detects.
                for anchor in anchors {
                    /// The hand skeleton that associates the anchor.
                    guard let handSkeleton = anchor.handSkeleton else {
                        continue
                    }

                    /// The current position and orientation of the thumb tip.
                    let thumbPos = (anchor.originFromAnchorTransform * handSkeleton.joint(.thumbTip).anchorFromJointTransform).translation()

                    /// The current position and orientation of the index finger tip.
                    let indexPos = (anchor.originFromAnchorTransform * handSkeleton.joint(.indexFingerTip).anchorFromJointTransform).translation()

                    /// The threshold to check if the index and thumb are close.
                    let pinchThreshold: Float = 0.05

                    // Update the last index position if the distance
                    // between the thumb tip and index finger tip is
                    // less than the pinch threshold.
                    if length(thumbPos - indexPos) < pinchThreshold {
                        lastIndexPose = indexPos
                    }
                }
            }))
//        } update: { updateContent in
//            let handsCenterTransform = gestureModel.computeTransformOfUserPerformedHeartGesture()
//            if let handsCenter = handsCenterTransform {
//                let position = Pose3D(handsCenter)!.position
//                let rotation = Pose3D(handsCenter)!.rotation
//                
//                // Rolling average window of N, ~2-30 frames
//                vx1[wIndex] = rotation.vector.x
//                vy1[wIndex] = rotation.vector.y
//                vz1[wIndex] = rotation.vector.z
//                vw1[wIndex] = rotation.vector.w
//                
//                let averageX = vDSP.mean(vx1)
//                let averageY = vDSP.mean(vy1)
//                let averageZ = vDSP.mean(vz1)
//                let averageW = vDSP.mean(vw1)
//                
//                wIndex += 1
//                wIndex %= windowSize
//                
//                beamIntermediate.transform.translation = SIMD3<Float>(position.vector)
//                beamIntermediate.transform.rotation = simd_quatf(vector: [Float(averageX), Float(averageY), Float(averageZ), Float(averageW)])
//                lastHeartDetectionTime = Date.timeIntervalSinceReferenceDate
//                
//                if gameModel.isSharePlaying {
//                    sendBeamPositionUpdate(Pose3D(handsCenter)!)
//                }
//            }
//            
//            let shouldShowBeam = handsCenterTransform != nil
//            if !gameModel.isPaused && gameModel.isPlaying {
//                if shouldShowBeam {
//                    if isShowingBeam == false {
//                        beamIntermediate.addChild(beam)
//                        startBlasterBeam(for: beam, beamType: .gesture)
//                    }
//                    isShowingBeam = true
//                    
//                } else if !shouldShowBeam && isShowingBeam == true {
//                    if Date.timeIntervalSinceReferenceDate > lastHeartDetectionTime + 0.1 {
//                        isShowingBeam = false
//                        beamIntermediate.removeChild(beam)
//                        endBlasterBeam()
//                    }
//                }
//            }
        }
        .gesture(DragGesture(minimumDistance: 0.0)
            .targetedToAnyEntity()
            .onChanged { @MainActor drag in
                if let pos = lastIndexPose {
                    // Add the current position to the canvas.
                    fullAppState.canvas.addPoint(pos)
                    
                    // SHAREPLAY
                    if fullAppState.contentViewModel.sharePlayEnabled {
                        
                        let entity = drag.entity
                        
                        var newPose3D = Pose3D(entity.transform.matrix)!
                        
                        fullAppState.contentViewModel.addNetworkedPointAtPos(newPose3D)
                        
                    }
                }
//                let entity = drag.entity
//                guard entity[parentMatching: "Heart Projector"] != nil else { return }
//                
//                if draggedEntity == nil || emittingBeam == false {
//                    draggedEntity = entity
//                    emittingBeam = true
//                    startBlasterBeam(for: entity, beamType: .turret)
//                }
//                
//                emittingBeam = !gameModel.isPaused
//                
//                if !isFloorBeamShowing && !gameModel.isPaused && gameModel.isPlaying {
//                    entity.addChild(floorBeam)
//                    
//                    floorBeam.orientation = simd_quatf(
//                        Rotation3D(angle: .degrees(90), axis: .z)
//                            .rotated(by: .init(angle: .degrees(180), axis: .y))
//                    )
//                    
//                    isFloorBeamShowing = true
//                }
//                
//                // Slow the rotation down.
//                let dragPoint = Point3D(drag.gestureValue.translation3D.vector) / 300
//                let zRotation = (-180 * (dragPoint.x)).clamped(to: -90...90)
//                let yRotation = (-180 * (dragPoint.y)).clamped(to: -90...90)
//            
//                let newOrientation = Rotation3D(angle: .degrees(Double(zRotation)), axis: .z)
//                    .rotated(
//                        by: .init(angle: .degrees(Double(yRotation)), axis: .x)
//                    )
//                
//                entity.orientation = simd_quatf(newOrientation)
//                
//                if gameModel.isSharePlaying {
//                    sendBeamPositionUpdate(Pose3D(entity.transform.matrix)!)
//                }
            }
            .onEnded { dragEnd in
//                if !gameModel.isPaused {
//                    floorBeam.removeFromParent()
//                    isFloorBeamShowing = false
//                    globalHeart?.children[0].transform.rotation = .init()
//                }
//                endBlasterBeam()
                fullAppState.canvas.finishStroke() // End the current stroke when the drag gesture ends.

                // SHAREPLAY
                if fullAppState.contentViewModel.sharePlayEnabled {
                    
                    fullAppState.contentViewModel.finishStroke()
                    
                }
                
            }
        )
        .task {
            await gestureModel.start()
        }
        .task {
            await gestureModel.publishHandTrackingUpdates()
        }
        .task {
            await gestureModel.monitorSessionEvents()
        }
        .onChange(of: gameModel.controllerLastInput) {
            gameControllerLoop()
        }
    }
    
    // Send each player's beam data during FaceTime calls that are spatial.
    func sendBeamPositionUpdate(_ pose: Pose3D) {
        if let sessionInfo = sessionInfo, let session = sessionInfo.session, let messenger = sessionInfo.messenger {
            let everyoneElse = session.activeParticipants.subtracting([session.localParticipant])
            
            if isShowingBeam, gameModel.isSpatial {
                messenger.send(BeamMessage(pose: pose), to: .only(everyoneElse)) { error in
                    if let error = error { print("Message failure:", error) }
                }
            }
        }
    }
    
    /// Stops showing the animated beam.
    @MainActor
    func endBlasterBeam() {
        Task.detached { @MainActor in
            emittingBeam = false
            if let collision = draggedEntity?.findEntity(named: collisionEntityName) {
                collision.removeFromParent()
            }
            draggedEntity = nil
        }
    }
    
    /// Displays the beam and starts its animation and moving collision entity.
    @MainActor
    func startBlasterBeam(for entity: Entity, beamType: BeamType) {
        Task() { @MainActor in
            lastGestureUpdateTime = Date.timeIntervalSinceReferenceDate
            emittingBeam = true
            draggedEntity = entity
            while emittingBeam == true {
                let elapsedTime = Date.timeIntervalSinceReferenceDate - lastGestureUpdateTime
                
                collisionEntity.removeFromParent()
                collisionEntity.name = collisionEntityName
                var root = entity
                while root.parent != nil {
                    if let parent = root.parent {
                        root = parent
                    }
                }

                root.addChild(collisionEntity)
                if collisionEntity.components[CollisionComponent.self] == nil {
                    let radius = (beamType == .turret) ? Float(0.1) : Float(0.5)
                    let collisionShape = ShapeResource.generateSphere(radius: radius)
                    let collisionComp = CollisionComponent(shapes: [collisionShape])
                    collisionEntity.components.set(collisionComp)
                }
                
                blasterPosition += Float(elapsedTime) * 1.5
                blasterPosition -= floorf(blasterPosition)
                entity.setMaterialParameterValues(parameter: DoodleVisionAssets.beamPositionParameterName, value: .float(blasterPosition))
                let offset: Float = (beamType == .turret) ? 23 : 1400
                let offsetVector: SIMD3<Float> = (beamType == .turret)
                    ? [0, 1, 0] * offset * blasterPosition
                    : [1, 0, 0] * offset * blasterPosition
                
                collisionEntity.setPosition(offsetVector, relativeTo: entity)

                lastGestureUpdateTime = Date.timeIntervalSinceReferenceDate
                try? await Task.sleep(for: .milliseconds(66.666_666))
            }
            collisionEntity.removeFromParent()
        }
    }
    
    /// Continously updates the beam position in response to input from a game controller.
    @MainActor
    func gameControllerLoop() {
        Task { @MainActor in
            #if targetEnvironment(simulator)
            let speed: Float = 0.4
            #else
            let speed: Float = 0.7
            #endif
            gameModel.controllerX += gameModel.controllerInputX * speed
            gameModel.controllerY -= gameModel.controllerInputY * speed
            
            let heart = globalHeart!
            if !isFloorBeamShowing && (gameModel.controllerInputX != 0.0 || gameModel.controllerInputX != 0.0) {
                heart.addChild(floorBeam)
                emittingBeam = true
                startBlasterBeam(for: heart, beamType: .turret)
                floorBeam.orientation = simd_quatf(
                    Rotation3D(angle: .degrees(90), axis: .z)
                        .rotated(by: .init(angle: .degrees(180), axis: .y))
                )
                isFloorBeamShowing = true
            }
            
            heart.orientation = simd_quatf(
                Rotation3D(angle: .degrees(Double(-gameModel.controllerX)), axis: .z)
                    .rotated(by: .init(angle: .degrees(Double(-gameModel.controllerY)), axis: .x))
            )
            
            if let timer = gameModel.controllerDismissTimer {
                timer.invalidate()
            }

            gameModel.controllerDismissTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                Task { @MainActor in
                    heart.removeChild(floorBeam)
                    isFloorBeamShowing = false
                    endBlasterBeam()
                }
            }
        }
    }
}

// Storage for the rolling average of the beam's rotation during hand gestures.
var windowSize = 24
var vx1: [Double] = .init(repeating: 0, count: windowSize)
var vy1: [Double] = .init(repeating: 0, count: windowSize)
var vz1: [Double] = .init(repeating: 0, count: windowSize)
var vw1: [Double] = .init(repeating: 0, count: windowSize)
var wIndex = 0

let collisionEntityName = "movingCollider"

enum BeamType {
    case turret
    case gesture
}

var isShowingBeam = false {
    didSet {
        if oldValue != isShowingBeam {
            AccessibilityNotification.Announcement(isShowingBeam ? String(localized: "Casting beam") : String(localized: "Hiding beam")).post()
        }
    }
}

var lastHeartDetectionTime = Date.timeIntervalSinceReferenceDate

/// Adds the purple base and golden heart models when someone picks an input mode that requires them.
@MainActor
func addFloorBeamMaterials() async throws {
    guard
        let turret = turret,
        let heart = heart
    else {
        fatalError("Required assets are nil.")
    }
    
    globalHeart = heart
    spaceOrigin.addChild(turret)
    spaceOrigin.addChild(heart)
}

/// Loads assets from the local DoodleVisionAssets package.
@MainActor
func loadFromRealityComposerPro(named entityName: String, fromSceneNamed sceneName: String) async -> Entity? {
    var entity: Entity? = nil
    do {
        let scene = try await Entity(named: sceneName, in: doodleVisionAssetsBundle)
        entity = scene.findEntity(named: entityName)
    } catch {
        print("Error loading \(entityName) from scene \(sceneName): \(error.localizedDescription)")
    }
    return entity
}

/// Checks whether a collision event contains one of a list of named entities.
func eventHasTargets(event: CollisionEvents.Began, matching names: [String]) -> Entity? {
    for targetName in names {
        if let target = eventHasTarget(event: event, matching: targetName) {
            return target
        }
    }
    return nil
}

/// Checks whether a collision event contains an entity that matches the name you supply.
func eventHasTarget(event: CollisionEvents.Began, matching targetName: String) -> Entity? {
    let aParentBeam = event.entityA[parentMatching: targetName]
    let aChildBeam = event.entityA[descendentMatching: targetName]
    let bParentBeam = event.entityB[parentMatching: targetName]
    let bChildBeam = event.entityB[descendentMatching: targetName]
    
    if aParentBeam == nil && aChildBeam == nil && bParentBeam == nil && bChildBeam == nil {
        return nil
    }
    
    var beam: Entity?
    if aParentBeam != nil || aChildBeam != nil {
        beam = (aParentBeam == nil) ? aChildBeam : aParentBeam
    } else if bParentBeam != nil || bChildBeam != nil {
        beam = (bParentBeam == nil) ? bChildBeam : bParentBeam
    }
    
    return beam
}
