//
//  FullAppState.swift
//  DoodleVision
//
//  Created by Huy Le on 11/16/24.
//  Copyright © 2024 Apple. All rights reserved.
//

import AVKit
import RealityKit
import SwiftUI

@MainActor
@Observable
class FullAppState {
    
    var canvas = PaintingCanvas()
    var contentViewModel = ContentViewModel()
    
    init() {
        contentViewModel.fullAppState = self
    }
}
