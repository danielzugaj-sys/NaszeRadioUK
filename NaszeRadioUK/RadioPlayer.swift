//
//  RadioPlayer.swift
//  NaszeRadioUK
//
//  Zaktualizowano: AUTOSTART + Obsługa powrotu internetu (NWPathMonitor)
//

import Network
import AVFoundation
import Foundation
import Combine
import UIKit
import MediaPlayer

class RadioPlayer: NSObject, ObservableObject {
    
    // MARK: - Stan Aplikacji
    @Published var isPlaying = false
    
    // Domyślnie TRUE - kółko kręci się od razu po włączeniu apki
    @Published var isLoading = true
    
    @Published var currentTrack = "Nasze Radio UK"
    @Published var connectionError: String? = nil
    
    // Głośność
    @Published var volume: Float = 1.0 {
        didSet {
            player?.volume = volume
        }
    }
    
    // MARK: - Zmienne wewnętrzne
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var metadataTimer: Timer?
    
    // Monitorowanie sieci (NOWOŚĆ)
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")
    
    // Flaga intencji użytkownika (Czy radio powinno grać?)
    // Ustawione na true, bo masz autostart
    var shouldBePlaying: Bool = true
    
    // Auto-Reconnect (stary timer, zostawiamy jako zapas)
    private var retryTimer: Timer?
    private var retryAttempts = 0
    private let maxRetryAttempts = 80
    
    // Adresy
    private let streamURL = "https://s9.citrus3.com:8226/"
    private let metadataURL = "https://s9.citrus3.com:2020/json/stream/naszeradiouk"

    // MARK: - Init
    override init() {
        super.init()
        setupAudioSession()
        setupPlayer()
        setupRemoteTransportControls()
        startMetadataTimer()
        
        // Uruchomienie monitora sieci (NOWOŚĆ)
        setupNetworkMonitor()
        
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
        
        // Autostart
        play()
    }

    // MARK: - Konfiguracja Sieci (NOWOŚĆ - NAPRAWA BŁĘDU)
    private func setupNetworkMonitor() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            
            if path.status == .satisfied {
                print("🌍 Internet dostępny!")
                
                // Jeśli internet wrócił, a radio powinno grać (użytkownik nie dał pauzy)
                // ORAZ radio aktualnie nie gra (lub się buforuje w nieskończoność)
                if self.shouldBePlaying {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        // Jeśli mimo powrotu sieci player nie gra, robimy twardy restart
                        if self.player?.timeControlStatus != .playing {
                            self.reloadStation()
                        }
                    }
                }
            } else {
                print("❌ Utracono połączenie z internetem")
                DispatchQueue.main.async {
                    self.isLoading = true // Pokazujemy kółko, bo nie ma neta
                }
            }
        }
        monitor.start(queue: monitorQueue)
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Błąd konfiguracji audio: \(error)")
        }
    }

    // Standardowa konfiguracja playera
    private func setupPlayer() {
        guard let url = URL(string: streamURL) else { return }
        
        if let item = playerItem {
            removeItemObservers(item: item)
        }
        
        playerItem = AVPlayerItem(url: url)
        addItemObservers(item: playerItem!)
        
        if player == nil {
            player = AVPlayer(playerItem: playerItem)
            player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
            // Ważne dla streamingu:
            player?.automaticallyWaitsToMinimizeStalling = true
        } else {
            player?.replaceCurrentItem(with: playerItem)
        }
        
        player?.volume = volume
    }
    
    // Funkcja do "twardego" restartu po powrocie internetu
    private func reloadStation() {
        print("🔄 Restartowanie strumienia po powrocie sieci...")
        guard let url = URL(string: streamURL) else { return }
        
        // Tworzymy nowy item, żeby pozbyć się "martwego" połączenia
        let newItem = AVPlayerItem(url: url)
        
        if let currentItem = playerItem {
            removeItemObservers(item: currentItem)
        }
        playerItem = newItem
        addItemObservers(item: newItem)
        
        player?.replaceCurrentItem(with: newItem)
        player?.play()
        
        DispatchQueue.main.async {
            self.isLoading = true // Chwilowe kółko podczas ładowania
            self.isPlaying = true
        }
    }
    
    // MARK: - Obserwatory KVO
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
    
    // MARK: - Sterowanie
    func play() {
        shouldBePlaying = true // Użytkownik chce słuchać
        connectionError = nil
        retryAttempts = 0
        retryTimer?.invalidate()
        
        try? AVAudioSession.sharedInstance().setActive(true)
        
        if player?.currentItem == nil {
            setupPlayer()
        }
        
        player?.play()
        isLoading = true
    }

    func pause() {
        shouldBePlaying = false // Użytkownik zatrzymał celowo
        retryTimer?.invalidate()
        player?.pause()
        isPlaying = false
        isLoading = false
    }
    
    func stop() {
        shouldBePlaying = false // Użytkownik zatrzymał celowo
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
    
    // MARK: - Wykrywanie Stanu (Kółko vs Play)
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        DispatchQueue.main.async {
            guard let player = self.player else { return }
            
            // Jeśli brakuje danych w buforze -> Kółko
            if keyPath == "playbackBufferEmpty" {
                if player.currentItem?.isPlaybackBufferEmpty == true {
                    self.isLoading = true
                }
            }
            
            // Jeśli bufor pełny i GRA -> Chowamy Kółko
            if keyPath == "playbackLikelyToKeepUp" {
                if player.currentItem?.isPlaybackLikelyToKeepUp == true && self.shouldBePlaying {
                    // Tylko jeśli użytkownik chce grać
                    if player.timeControlStatus == .playing || player.timeControlStatus == .waitingToPlayAtSpecifiedRate {
                         self.isLoading = false
                         self.isPlaying = true
                         self.retryAttempts = 0
                    }
                }
            }
            
            if keyPath == "timeControlStatus" {
                if player.timeControlStatus == .playing {
                    if player.currentItem?.isPlaybackLikelyToKeepUp == true {
                        self.isLoading = false
                        self.isPlaying = true
                        self.updateNowPlayingInfo(title: self.currentTrack)
                    }
                } else if player.timeControlStatus == .waitingToPlayAtSpecifiedRate {
                    self.isLoading = true
                } else if player.timeControlStatus == .paused {
                    // Jeśli zapauzowano, ale shouldBePlaying jest true, to znaczy że to buforowanie lub błąd sieci
                    if self.shouldBePlaying {
                        self.isLoading = true
                    } else {
                        self.isPlaying = false
                        self.isLoading = false
                    }
                }
            }
            
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
    
    // MARK: - Obsługa błędów playera
    @objc func playerDidFinishPlaying(note: NSNotification) {
        print("Player zakończył/błąd. Próba reconnectu...")
        
        // Tylko jeśli użytkownik nie zatrzymał ręcznie
        if shouldBePlaying {
            DispatchQueue.main.async {
                self.isPlaying = false
                self.isLoading = true
                self.attemptReconnect()
            }
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
        retryTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            if self.shouldBePlaying {
                self.reloadStation() // Używamy teraz reloadStation zamiast zwykłego setup
            }
        }
    }

    // MARK: - Przerwania (Telefon)
    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }

        if type == .began {
            // Rozmowa przychodząca - pauza, ale nie zmieniamy shouldBePlaying na false,
            // bo chcemy wrócić po rozmowie (chyba że tak wolisz)
            player?.pause()
        } else if type == .ended {
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) && shouldBePlaying {
                    player?.play()
                }
            }
        }
    }
    
    // MARK: - Centrum Sterowania
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
    
    // MARK: - Metadata
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
        monitor.cancel() // Zatrzymujemy monitor sieci
        metadataTimer?.invalidate()
        retryTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
        if let item = playerItem { removeItemObservers(item: item) }
        player?.removeObserver(self, forKeyPath: "timeControlStatus")
    }
}
