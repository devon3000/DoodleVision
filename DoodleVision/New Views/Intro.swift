//
//  Intro.swift
//  DoodleVision
//
//  Created by Huy Le on 11/16/24.
//  Copyright © 2024 Apple. All rights reserved.
//

import Combine
import SwiftUI
@preconcurrency import GroupActivities
import RealityKit

struct Intro: View {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    // @Environment(NewGameModel.self) var newGameModel
    
    
    @State private var subscriptions = Set<AnyCancellable>()
    
    var body: some View {
        
        // let gameState = NewGameScreen.from(state: newGameModel)
        
        VStack {
            Spacer()
            Group {
                NewStart()

                /*
                switch gameState {
                case.start:
                }
                 */
            }
            .glassBackgroundEffect(
                in: RoundedRectangle(
                    cornerRadius: 32,
                    style: .continuous
                )
            )
        }
    }
}

#Preview {
    Intro()
        // .environment(NewGameModel())
}

enum NewGameScreen {
    /*
    static func from(state: NewGameModel) -> Self {
        return .start
    }
     */
    
    case start
}
