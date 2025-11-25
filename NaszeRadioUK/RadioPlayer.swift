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
    @Published var currentTrack = "Nasze Radio UK"
    
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
        
        // 1. METODA PEWNA (Mimo że generuje ostrzeżenie, działa najlepiej)
        // Dodajemy obserwatora do danych zaszytych w dźwięku
        playerItem.addObserver(self, forKeyPath: "timedMetadata", options: .new, context: nil)
        
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
        DispatchQueue.main.async {
            self.currentTrack = "Nasze Radio UK"
        }
    }
    
    // MARK: - METODA 1: ODCZYT ZE STRUMIENIA (To przywracamy!)
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "timedMetadata" {
            guard let item = object as? AVPlayerItem, let metadata = item.timedMetadata else { return }
            
            for item in metadata {
                if let stringValue = item.stringValue {
                    DispatchQueue.main.async {
                        // Aktualizujemy tytuł natychmiast, gdy przyjdzie z dźwiękiem
                        self.currentTrack = stringValue
                        print("Tytuł ze strumienia: \(stringValue)")
                    }
                }
            }
        }
    }
    
    // MARK: - METODA 2: ODCZYT Z JSON (Jako zapas + Debugowanie)
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

            // Dodaliśmy logowanie, żebyś widział w konsoli co odbierasz
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Odebrany JSON: \(jsonString)")
            }

            do {
                // Próbujemy różnych struktur JSON, bo serwery bywają różne
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    
                    var newTitle: String?
                    
                    // Opcja A: Standardowa
                    if let stream = json["stream"] as? [String: Any], let title = stream["title"] as? String {
                        newTitle = title
                    }
                    // Opcja B: Płaska struktura
                    else if let title = json["title"] as? String {
                        newTitle = title
                    }
                    // Opcja C: Struktura mountpoint
                    else if let mounts = json["mounts"] as? [String: Any],
                            let defaultMount = mounts["/stream"] as? [String: Any],
                            let title = defaultMount["title"] as? String {
                        newTitle = title
                    }

                    if let validTitle = newTitle, !validTitle.isEmpty {
                        DispatchQueue.main.async {
                            self.currentTrack = validTitle
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
        player?.currentItem?.removeObserver(self, forKeyPath: "timedMetadata")
    }
}
