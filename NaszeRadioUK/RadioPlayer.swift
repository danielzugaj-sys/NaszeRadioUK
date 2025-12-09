//
//  RadioPlayer.swift
//  NaszeRadioUK
//
//  POPRAWKA: Kółko ładowania teraz czeka na faktyczny dźwięk (bufor).
//

import Foundation
import AVFoundation
import Combine
import UIKit
import MediaPlayer

class RadioPlayer: NSObject, ObservableObject {
    
    // MARK: - Stan Aplikacji
    @Published var isPlaying = false
    @Published var isLoading = false
    @Published var currentTrack = "Nasze Radio UK"
    @Published var connectionError: String? = nil
    
    // Głośność
    @Published var volume: Float = 1.0 {
        didSet {
            player?.volume = volume
        }
    }
    
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var metadataTimer: Timer?
    
    // Auto-Reconnect
    private var retryTimer: Timer?
    private var retryAttempts = 0
    private let maxRetryAttempts = 80 // 2 minuty
    
    // Adresy
    private let streamURL = "https://s9.citrus3.com:8226/"
    private let metadataURL = "https://s9.citrus3.com:2020/json/stream/naszeradiouk"

    override init() {
        super.init()
        setupAudioSession()
        setupPlayer()
        setupRemoteTransportControls()
        startMetadataTimer()
        
        // Obserwatory systemowe
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleInterruption),
                                               name: AVAudioSession.interruptionNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidFinishPlaying),
                                               name: .AVPlayerItemFailedToPlayToEndTime,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidFinishPlaying),
                                               name: .AVPlayerItemPlaybackStalled,
                                               object: nil)
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Błąd konfiguracji audio: \(error)")
        }
    }

    private func setupPlayer() {
        guard let url = URL(string: streamURL) else { return }
        
        // Czyścimy stary item jeśli był
        if let item = playerItem {
            removeItemObservers(item: item)
        }
        
        playerItem = AVPlayerItem(url: url)
        // Dodajemy obserwatory do NOWEGO itemu
        addItemObservers(item: playerItem!)
        
        if player == nil {
            player = AVPlayer(playerItem: playerItem)
            player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        } else {
            player?.replaceCurrentItem(with: playerItem)
        }
        
        player?.volume = volume
    }
    
    // MARK: - Dodawanie/Usuwanie Obserwatorów (WAŻNE!)
    
    private func addItemObservers(item: AVPlayerItem) {
        item.addObserver(self, forKeyPath: "timedMetadata", options: .new, context: nil)
        item.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        item.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
        item.addObserver(self, forKeyPath: "status", options: .new, context: nil)
    }
    
    private func removeItemObservers(item: AVPlayerItem) {
        item.removeObserver(self, forKeyPath: "timedMetadata")
        item.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        item.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        item.removeObserver(self, forKeyPath: "status")
    }
    
    // MARK: - LOGIKA PLAY / PAUSE
    
    func play() {
        connectionError = nil
        retryAttempts = 0
        retryTimer?.invalidate()
        
        try? AVAudioSession.sharedInstance().setActive(true)
        
        // Jeśli player zgubił item (np. po błędzie), odnów go
        if player?.currentItem == nil {
            setupPlayer()
        }
        
        player?.play()
        isLoading = true // Wymuszamy kółko na start
    }

    func pause() {
        retryTimer?.invalidate()
        player?.pause()
        isPlaying = false
        isLoading = false
    }
    
    func stop() {
        retryTimer?.invalidate()
        player?.pause()
        player?.seek(to: .zero)
        isPlaying = false
        isLoading = false
        DispatchQueue.main.async {
            self.currentTrack = "Nasze Radio UK"
            self.updateNowPlayingInfo(title: "Nasze Radio UK")
        }
    }
    
    // MARK: - OBSŁUGA STATUSU (SERCE APLIKACJI)
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        DispatchQueue.main.async {
            guard let player = self.player else { return }
            
            // 1. Sprawdzamy, czy bufor jest pusty (kręcimy kółkiem)
            if keyPath == "playbackBufferEmpty" {
                if player.currentItem?.isPlaybackBufferEmpty == true {
                    self.isLoading = true
                }
            }
            
            // 2. Sprawdzamy, czy bufor jest pełny i gotowy do grania (chowamy kółko)
            if keyPath == "playbackLikelyToKeepUp" {
                if player.currentItem?.isPlaybackLikelyToKeepUp == true && player.timeControlStatus == .playing {
                    self.isLoading = false
                    self.isPlaying = true
                    self.retryAttempts = 0
                }
            }
            
            // 3. Status Playera (Zabezpieczenie)
            if keyPath == "timeControlStatus" {
                if player.timeControlStatus == .playing {
                    // Tylko jeśli bufor też jest gotowy, chowamy kółko
                    if player.currentItem?.isPlaybackLikelyToKeepUp == true {
                        self.isLoading = false
                        self.isPlaying = true
                        self.updateNowPlayingInfo(title: self.currentTrack)
                    }
                } else if player.timeControlStatus == .waitingToPlayAtSpecifiedRate {
                    self.isLoading = true
                } else if player.timeControlStatus == .paused {
                    self.isPlaying = false
                    // Nie zmieniamy isLoading tutaj, bo to może być chwilowy brak danych
                }
            }
            
            // 4. Metadane
            if keyPath == "timedMetadata" {
                guard let item = object as? AVPlayerItem, let metadata = item.timedMetadata else { return }
                for item in metadata {
                    if let stringValue = item.stringValue {
                        self.currentTrack = stringValue
                        self.updateNowPlayingInfo(title: stringValue)
                    }
                }
            }
        }
    }
    
    // MARK: - AUTO-RECONNECT
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        print("Utracono połączenie. Restart...")
        DispatchQueue.main.async {
            self.isPlaying = false
            self.isLoading = true
            self.attemptReconnect()
        }
    }
    
    private func attemptReconnect() {
        guard retryAttempts < maxRetryAttempts else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.isPlaying = false
                self.connectionError = "Brak połączenia z internetem."
            }
            return
        }
        
        retryAttempts += 1
        
        retryTimer?.invalidate()
        retryTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { [weak self] _ in
            self?.setupPlayer()
            self?.player?.play()
        }
    }

    // MARK: - OBSŁUGA PRZERWAŃ
    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }

        if type == .began {
            player?.pause()
        } else if type == .ended {
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    player?.play()
                }
            }
        }
    }
    
    // MARK: - Center Sterowania
    private func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.play()
            return .success
        }
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }
        updateNowPlayingInfo(title: "Nasze Radio UK")
    }
    
    private func updateNowPlayingInfo(title: String) {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyArtist] = "Nasze Radio UK"
        if let image = UIImage(named: "AppIcon") {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
        }
        nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = true
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    // MARK: - Metadata JSON
    private func startMetadataTimer() {
        fetchMetadata()
        metadataTimer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { [weak self] _ in
            self?.fetchMetadata()
        }
    }
    
    private func fetchMetadata() {
        let urlString = "\(metadataURL)?t=\(Date().timeIntervalSince1970)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil else { return }
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    var newTitle: String?
                    if let stream = json["stream"] as? [String: Any], let title = stream["title"] as? String { newTitle = title }
                    else if let title = json["title"] as? String { newTitle = title }
                    else if let mounts = json["mounts"] as? [String: Any], let dM = mounts["/stream"] as? [String: Any], let title = dM["title"] as? String { newTitle = title }
                    
                    if let validTitle = newTitle, !validTitle.isEmpty, validTitle != self.currentTrack {
                        DispatchQueue.main.async {
                            self.currentTrack = validTitle
                            self.updateNowPlayingInfo(title: validTitle)
                        }
                    }
                }
            } catch { }
        }.resume()
    }
    
    deinit {
        metadataTimer?.invalidate()
        retryTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
        if let item = playerItem { removeItemObservers(item: item) }
        player?.removeObserver(self, forKeyPath: "timeControlStatus")
    }
}
