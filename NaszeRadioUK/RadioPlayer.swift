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
    @Published var currentTrack = "Nasze Radio UK" // Domyślny tekst startowy
    
    private var player: AVPlayer?
    private var metadataTimer: Timer?
    
    // Adresy
    private let streamURL = "https://s9.citrus3.com:8226/"
    private let metadataURL = "https://s9.citrus3.com:2020/json/stream/naszeradiouk"

    override init() {
        super.init()
        setupPlayer()
        startMetadataTimer()
    }

    private func setupPlayer() {
        guard let url = URL(string: streamURL) else { return }
        
        let playerItem = AVPlayerItem(url: url)
        self.player = AVPlayer(playerItem: playerItem)
        
        // Konfiguracja Audio (Tło)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Błąd konfiguracji audio: \(error)")
        }
    }

    // MARK: - Metody Sterujące
    func play() {
        player?.play()
        isPlaying = true
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    func stop() {
        player?.pause()
        player?.seek(to: .zero)
        isPlaying = false
        // Przy stopie resetujemy tytuł do nazwy stacji
        DispatchQueue.main.async {
            self.currentTrack = "Nasze Radio UK"
        }
    }
    
    // MARK: - ODCZYT METADANYCH Z JSON (Metoda Stabilna)
    private func startMetadataTimer() {
        fetchMetadata()
        // Odświeżanie co 10 sekund
        metadataTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            self?.fetchMetadata()
        }
    }
    
    private func fetchMetadata() {
        // Dodajemy losowy parametr czasu, żeby ominąć cache (?t=...)
        let urlString = "\(metadataURL)?t=\(Date().timeIntervalSince1970)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil else { return }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let streamData = json["stream"] as? [String: Any],
                   let title = streamData["title"] as? String {
                    
                    // Aktualizujemy tylko jeśli tytuł nie jest pusty i różni się od obecnego
                    if !title.isEmpty && title != self.currentTrack {
                        DispatchQueue.main.async {
                            self.currentTrack = title
                        }
                    }
                }
            } catch {
                print("Błąd JSON: \(error)")
            }
        }.resume()
    }
    
    deinit {
        metadataTimer?.invalidate()
    }
}
