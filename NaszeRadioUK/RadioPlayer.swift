//
//  RadioPlayer.swift
//  NaszeRadioUK
//
//  Zaktualizowano: Szybki Reconnect (co 1.5 sekundy)
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
    
    // Zmienne do Auto-Reconnect (SZYBKIE WZNAWIANIE)
    private var retryTimer: Timer?
    private var retryAttempts = 0
    // 80 prób * 1.5 sekundy = 120 sekund (2 minuty walki o sygnał)
    private let maxRetryAttempts = 80
    
    // Adresy
    private let streamURL = "https://s9.citrus3.com:8226/"
    private let metadataURL = "https://s9.citrus3.com:2020/json/stream/naszeradiouk"

    override init() {
        super.init()
        setupAudioSession()
        setupPlayer()
        setupRemoteTransportControls()
        startMetadataTimer()
        
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
        
        playerItem = AVPlayerItem(url: url)
        playerItem?.addObserver(self, forKeyPath: "timedMetadata", options: .new, context: nil)
        
        if player == nil {
            player = AVPlayer(playerItem: playerItem)
        } else {
            player?.replaceCurrentItem(with: playerItem)
        }
        
        player?.volume = volume
        
        // Obserwator STATUSU (To odpowiada za kręcące się kółko)
        player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
    }
    
    // MARK: - LOGIKA PLAY / PAUSE
    
    func play() {
        connectionError = nil
        retryAttempts = 0
        retryTimer?.invalidate()
        
        try? AVAudioSession.sharedInstance().setActive(true)
        player?.play()
        isLoading = true // Wymuszamy pokazanie kółka na start
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
    
    // MARK: - OBSŁUGA STATUSU
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "timeControlStatus", let player = player {
            DispatchQueue.main.async {
                if player.timeControlStatus == .playing {
                    // GRA: Pokazujemy Pauzę, chowamy kółko
                    self.isPlaying = true
                    self.isLoading = false
                    self.retryAttempts = 0
                    self.updateNowPlayingInfo(title: self.currentTrack)
                } else if player.timeControlStatus == .waitingToPlayAtSpecifiedRate {
                    // BUFORUJE: Pokazujemy Kółko
                    self.isLoading = true
                    self.isPlaying = false
                } else if player.timeControlStatus == .paused {
                    self.isPlaying = false
                    // isLoading zostawiamy bez zmian (chyba że to ręczna pauza obsłużona wyżej)
                }
            }
        }
        
        if keyPath == "timedMetadata" {
            guard let item = object as? AVPlayerItem, let metadata = item.timedMetadata else { return }
            for item in metadata {
                if let stringValue = item.stringValue {
                    DispatchQueue.main.async {
                        self.currentTrack = stringValue
                        self.updateNowPlayingInfo(title: stringValue)
                    }
                }
            }
        }
    }
    
    // MARK: - SZYBKI AUTO-RECONNECT (1.5 sekundy)
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        print("Utracono połączenie. Rozpoczynam szybkie wznawianie...")
        DispatchQueue.main.async {
            self.isPlaying = false
            self.isLoading = true // Kręcimy kółkiem podczas prób
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
        print("Próba połączenia: \(retryAttempts) (co 1.5s)")
        
        retryTimer?.invalidate()
        // ZMIANA: Czas skrócony do 1.5 sekundy
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
        player?.removeObserver(self, forKeyPath: "timeControlStatus")
        playerItem?.removeObserver(self, forKeyPath: "timedMetadata")
    }
}
