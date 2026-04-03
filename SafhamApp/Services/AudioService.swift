import AVFoundation
import Foundation

@MainActor
final class AudioService: NSObject, ObservableObject {
    @Published private(set) var currentlyPlayingWordKey: String?
    private var player: AVAudioPlayer?

    func playWord(key: String, reciter: Reciter, slowMode: Bool) {
        let filename = key.replacingOccurrences(of: ":", with: "_")
        guard let url = Bundle.main.url(
            forResource: filename,
            withExtension: "mp3",
            subdirectory: "Audio/\(reciter.folderName)"
        ) else {
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.enableRate = true
            player?.rate = slowMode ? 0.7 : 1.0
            player?.prepareToPlay()
            player?.play()
            currentlyPlayingWordKey = key
        } catch {
            currentlyPlayingWordKey = nil
        }
    }

    func stop() {
        player?.stop()
        currentlyPlayingWordKey = nil
    }
}
