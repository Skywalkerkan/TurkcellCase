//
//  MoviePlayerInteractor.swift
//  TurkcellCase
//
//  Created by Erkan on 31.05.2025.
//

import Foundation
import AVFoundation

protocol MoviePlayerInteractorProtocol: AnyObject {
    func setupPlayer()
    func play()
    func pause()
    func setMuted(_ muted: Bool)
    func setVolume(_ value: Float)
    func getVolume() -> Float
    func seek(to progress: Float)
}

protocol MoviePlayerInteractorOutputProtocol: AnyObject {
    func playerReady(totalTime: String)
    func playerProgressUpdated(currentTime: String, progress: Float)
    func playerCreated(player: AVPlayer)
    func playerDidFinish()
    func playerLoading()
}

final class MoviePlayerInteractor: NSObject {
    
    weak var output: MoviePlayerInteractorOutputProtocol?
    
    private var player: AVPlayer?
    private var timeObserver: Any?
    
    private var movieURLString: String
    
    init(movieURLString: String) {
        self.movieURLString = movieURLString
    }
    
    deinit {
        cleanup()
    }
    
    private func cleanup() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
        player?.pause()
        player = nil
    }
}

extension MoviePlayerInteractor: MoviePlayerInteractorProtocol {
    
    func setupPlayer() {
        guard let url = URL(string: movieURLString) else { return }
        output?.playerLoading()
        player = AVPlayer(url: url)
        
        addTimeObserver()
        observePlayerStatus()
        
        if let player = player {
            output?.playerCreated(player: player)
        }
    }
    
    private func addTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.updateProgress()
        }
    }
    
    private func updateProgress() {
        guard let player = player,
              let currentItem = player.currentItem else { return }
        
        let currentTime = player.currentTime()
        let duration = currentItem.duration
        
        if duration.seconds.isNaN || duration.seconds <= 0 { return }
        
        let currentSeconds = currentTime.seconds
        let totalSeconds = duration.seconds
        
        let currentTimeStr = formatTime(currentSeconds)
        let progressValue = Float(currentSeconds / totalSeconds)
        
        output?.playerProgressUpdated(currentTime: currentTimeStr, progress: progressValue)
    }
    
    private func observePlayerStatus() {
        player?.currentItem?.addObserver(self, forKeyPath: "status", options: [.new], context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying),
                                               name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            if player?.currentItem?.status == .readyToPlay {
                let duration = player?.currentItem?.duration.seconds ?? 0
                let totalTime = formatTime(duration)
                output?.playerReady(totalTime: totalTime)
            }
        }
    }
    
    @objc private func playerDidFinishPlaying() {
        output?.playerDidFinish()
    }
    
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    func setMuted(_ muted: Bool) {
        player?.isMuted = muted
    }
    
    func setVolume(_ value: Float) {
        player?.volume = value
    }
    
    func getVolume() -> Float {
        return player?.volume ?? 1.0
    }
    
    func seek(to progress: Float) {
        guard let duration = player?.currentItem?.duration else { return }
        let totalSeconds = duration.seconds
        let seekTime = Double(progress) * totalSeconds
        let cmTime = CMTime(seconds: seekTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.seek(to: cmTime)
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let totalSeconds = Int(seconds)
        let h = totalSeconds / 3600
        let m = (totalSeconds % 3600) / 60
        let s = totalSeconds % 60
        
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        } else {
            return String(format: "%02d:%02d", m, s)
        }
    }
}
