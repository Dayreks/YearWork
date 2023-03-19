/*
See LICENSE folder for this sample’s licensing information.
*/

import Foundation
import AVFoundation

extension AVPlayer {
    static let click1Player: AVPlayer = {
        guard let url = Bundle.main.url(forResource: "clickSound1", withExtension: "wav") else { fatalError("Failed to find sound file.") }
        return AVPlayer(url: url)
    }()
    
    static let click2Player: AVPlayer = {
        guard let url = Bundle.main.url(forResource: "clickSound2", withExtension: "wav") else { fatalError("Failed to find sound file.") }
        return AVPlayer(url: url)
    }()
    
    static let click3Player: AVPlayer = {
        guard let url = Bundle.main.url(forResource: "clickSound3", withExtension: "wav") else { fatalError("Failed to find sound file.") }
        return AVPlayer(url: url)
    }()
    
    static let click4Player: AVPlayer = {
        guard let url = Bundle.main.url(forResource: "clickSound4", withExtension: "wav") else { fatalError("Failed to find sound file.") }
        return AVPlayer(url: url)
    }()
}
