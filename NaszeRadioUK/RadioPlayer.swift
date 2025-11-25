//
//  RadioPlayer.swift
//  NaszeRadioUK
//
//  Created by user on 23/11/2025.
//
import Foundation
import AVFoundation
import Combine
import UIKit
import MediaPlayer

class RadioPlayer: NSObject, ObservableObject {
    
    // MARK: - Stan Aplikacji
    @Published var isPlaying = false
    @Published var currentTrack = "Nasze Radio UK"
    
    // Głośność (od 0.0 do 1.0)
    @Published var volume: Float = 1.0 {
        didSet {
            player?.volume = volume
        }
    }
    
    private var player: AVPlayer?
    private var metadataTimer: Timer?
    
    // Adresy
    private let streamURL = "https://s9.citrus3.com:8226/"
    private let metadataURL = "https://s9.citrus3.com:2020/json/stream/naszeradiouk"

    override init() {
        super.init()
        setupAudioSession()
        setupPlayer()
        setupRemoteTransportControls()
        startMetadataTimer()
        
        // Obserwator Przerwań (np. połączenie przychodzące, włączenie TikToka)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleInterruption),
                                               name: AVAudioSession.interruptionNotification,
                                               object: nil)
        
        play()
    }

    private func setupAudioSession() {
        do {
            // ZMIANA: Usunęliśmy [.mixWithOthers]. Teraz radio jest "główne" i ustępuje miejsca innym.
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Błąd konfiguracji audio: \(error)")
        }
    }

    private func setupPlayer() {
        guard let url = URL(string: streamURL) else { return }
        
        let playerItem = AVPlayerItem(url: url)
        
        // Obserwator metadanych ze strumienia (Metoda 1)
        playerItem.addObserver(self, forKeyPath: "timedMetadata", options: .new, context: nil)
        
        self.player = AVPlayer(playerItem: playerItem)
        self.player?.volume = volume
    }
    
    // MARK: - OBSŁUGA PRZERWAŃ (TikTok, Instagram, Połączenia)
    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        if type == .began {
            // Ktoś inny zaczął grać (np. TikTok) -> Pauzujemy
            print("Przerwanie: Początek (Pauza)")
            // Nie zmieniamy isPlaying na false w UI, żeby po powrocie wiedzieć, że trzeba wznowić
            player?.pause()
            
        } else if type == .ended {
            // Ktoś inny skończył grać -> Sprawdzamy czy wznowić
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    // Wznawiamy granie
                    print("Przerwanie: Koniec (Wznowienie)")
                    player?.play()
                    // Upewniamy się, że UI pokazuje Play
                    DispatchQueue.main.async {
                        self.isPlaying = true
                    }
                }
            }
        }
    }
    
    // MARK: - Konfiguracja Ekranu Blokady
    private func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { [weak self] event in
            self?.play()
            return .success
        }

        commandCenter.pauseCommand.addTarget { [weak self] event in
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

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    // MARK: - Metody Sterujące
    func play() {
        // Aktywacja sesji jest ważna przy wznawianiu po przerwie
        try? AVAudioSession.sharedInstance().setActive(true)
        player?.play()
        isPlaying = true
        updateNowPlayingInfo(title: currentTrack)
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    func stop() {
        player?.pause()
        player?.seek(to: .zero)
        isPlaying = false
        DispatchQueue.main.async {
            self.currentTrack = "Nasze Radio UK"
            self.updateNowPlayingInfo(title: "Nasze Radio UK")
        }
    }
    
    // MARK: - METODA 1: ODCZYT ZE STRUMIENIA
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
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
    
    // MARK: - METODA 2: ODCZYT Z JSON
    private func startMetadataTimer() {
        fetchMetadata()
        metadataTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
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
                    
                    if let stream = json["stream"] as? [String: Any], let title = stream["title"] as? String {
                        newTitle = title
                    } else if let title = json["title"] as? String {
                        newTitle = title
                    } else if let mounts = json["mounts"] as? [String: Any],
                            let defaultMount = mounts["/stream"] as? [String: Any],
                            let title = defaultMount["title"] as? String {
                        newTitle = title
                    }

                    if let validTitle = newTitle, !validTitle.isEmpty, validTitle != self.currentTrack {
                        DispatchQueue.main.async {
                            self.currentTrack = validTitle
                            self.updateNowPlayingInfo(title: validTitle)
                        }
                    }
                }
            } catch {
                print("Błąd parsowania JSON: \(error)")
            }
        }.resume()
    }
    
    deinit {
        metadataTimer?.invalidate()
        NotificationCenter.default.removeObserver(self) // Usuwamy obserwatora przerwań
        player?.currentItem?.removeObserver(self, forKeyPath: "timedMetadata")
    }
}
