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

class RadioPlayer: NSObject, ObservableObject {
    
    // MARK: - Stan Aplikacji
    
    @Published var isPlaying = false
    @Published var currentTrack = "Ładowanie stacji..."
    
    private var player: AVPlayer?
    private var metadataTimer: Timer?
    
    // ⚠️ ADRESY TWOICH STRUMIENI ⚠️
    private let streamURL = "https://s9.citrus3.com:8226/"
    private let metadataURL = "https://s9.citrus3.com:2020/json/stream/naszeradiouk"

    // MARK: - Inicjalizacja
    
    override init() {
        super.init()
        
        // 1. Inicjalizacja AVPlayer
        guard let url = URL(string: streamURL) else { return }
        let playerItem = AVPlayerItem(url: url)
        self.player = AVPlayer(playerItem: playerItem)
        
        // 2. Ustawienia sesji audio (Kluczowe dla działania w tle)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback,
                                                           mode: .default,
                                                           options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Błąd konfiguracji sesji audio: \(error)")
        }
        
        // 3. START POBIERANIA TYTUŁÓW Z JSON
        startMetadataTimer()
    }

    // MARK: - Metody Sterujące
    
    // Zmieniamy stan isPlaying Wewnątrz tej metody
    func play() {
        player?.play()
        isPlaying = true
    }

    // Zmieniamy stan isPlaying Wewnątrz tej metody
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    func stop() {
        player?.pause()
        player?.seek(to: .zero)
        isPlaying = false
    }
    
    // MARK: - Obsługa Metadanych (JSON API)

    private func startMetadataTimer() {
        fetchMetadata()
        
        // Timer odświeża tytuł co 5 sekund
        metadataTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.fetchMetadata()
        }
    }
    
    private func fetchMetadata() {
        guard let url = URL(string: metadataURL) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  error == nil else {
                return
            }

            // Parsowanie JSON
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let streamData = json["stream"] as? [String: Any],
                   let title = streamData["title"] as? String {
                    
                    // Aktualizacja UI na głównym wątku
                    DispatchQueue.main.async {
                        self.currentTrack = title
                    }
                }
            } catch {
                print("Błąd parsowania JSON: \(error)")
            }
        }.resume()
    }
    
    // MARK: - Czyszczenie
    
    deinit {
        metadataTimer?.invalidate()
    }
}
