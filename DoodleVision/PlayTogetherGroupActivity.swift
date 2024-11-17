import Foundation
import GroupActivities
import UIKit

struct PlayTogetherGroupActivity: GroupActivity {
    // Define a unique activity identifier for system to reference
    static let activityIdentifier = "com.visionhack.DoodleVision.PlayTogether"

    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = "DoodleVision SharePlay Tutorial"
        metadata.subtitle = "Let's play together!"
        metadata.previewImage = UIImage(named: "birdicon")?.cgImage
        metadata.type = .generic
        return metadata
    }
}
