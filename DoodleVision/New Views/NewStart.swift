//
//  NewStart.swift
//  DoodleVision
//
//  Created by Huy Le on 11/16/24.
//  Copyright © 2024 Apple. All rights reserved.
//

import SwiftUI
import GroupActivities

struct NewStart: View {
    // @Environment(NewGameModel.self) var newGameModel
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    
    @StateObject private var groupStateObserver = GroupStateObserver()
    
    var body: some View {
        VStack(spacing: 10) {
            Spacer()
            Text("Doodle Vision", comment: "The name of the game.")
                .font(.system(size: 30, weight: .bold))
            Text("Try drawing with friends.", comment: "This text explains the purpose of the game.")
                .multilineTextAlignment(.center)
                .font(.headline)
                .frame(width: 340)
                .padding(.bottom, 10)
            
            Spacer()
        }
        .padding(.horizontal, 150)
        .frame(width: 634, height: 499)
        .onAppear {
            /*
            gameModel.menuPlayer.volume = 0.6
            gameModel.menuPlayer.numberOfLoops = -1
            gameModel.menuPlayer.currentTime = 0
            gameModel.menuPlayer.play()
             */
        }
    }
}

#Preview {
    NewStart()
        // .environment(NewGameModel())
        .glassBackgroundEffect(
            in: RoundedRectangle(
                cornerRadius: 32,
                style: .continuous
            )
        )
}
