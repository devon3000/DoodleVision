//
//  SharePlayMessage.swift
//  DoodleVision
//
//  Created by Huy Le on 11/16/24.
//  Copyright © 2024 Apple. All rights reserved.
//

import Spatial
import GroupActivities
import Foundation

struct EnlargeMessage: Codable {
    let enlarged: Bool
}

struct PaintMessage: Codable {
    let pose: Pose3D
}

struct AddPointMessage: Codable {
    let pose: Pose3D
}

struct FinishStrokeMessage: Codable {
    
}
