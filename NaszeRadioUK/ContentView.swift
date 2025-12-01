import SwiftUI

struct ContentView: View {
    
    @StateObject var radioPlayer = RadioPlayer()

    let backgroundImageName = "HexagonBackground"
    let mainLogoName = "MainLogo"
    
    // Konfiguracja czarnego paska
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView {
            // MARK: - 1. Główny Ekran Radiowy
            ZStack {
                Image(backgroundImageName).resizable().scaledToFill().ignoresSafeArea()

                // GŁÓWNY KONTENER (Układ jak w Reklamie)
                VStack(spacing: 0) {
                    
                    // 1. GÓRNY SPACER (Spycha wszystko na środek)
                    Spacer()
                    
                    // 2. TREŚĆ WŁAŚCIWA (Logo + Player)
                    VStack(spacing: 0) {
                        // Logo
                        Image(mainLogoName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 300)
                            .padding(.bottom, 30) // Zmniejszony odstęp, żeby było spójnie
                        
                        // Tytuł
                        Text(radioPlayer.currentTrack)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.bottom, 40)
                        
                        // Play Button
                        Button(action: {
                            if radioPlayer.isPlaying { radioPlayer.pause() } else { radioPlayer.play() }
                        }) {
                            Image(systemName: radioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 100))
                                .foregroundColor(Color.white)
                                .shadow(radius: 10)
                        }
                        .padding(.bottom, 40)
                        
                        // Suwak
                        VStack {
                            HStack {
                                Image(systemName: "speaker.fill").foregroundColor(.gray)
                                Slider(value: $radioPlayer.volume, in: 0...1).accentColor(.white)
                                Image(systemName: "speaker.wave.3.fill").foregroundColor(.white)
                            }
                            .padding(.horizontal, 40)
                        }
                    }
                    
                    // 3. DOLNY SPACER
                    Spacer()
                    
                    // Stopka
                    Text("Nasze Radio UK © 2025")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                }
                .frame(maxWidth: 600) // Ograniczenie szerokości
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Centrowanie
            }
            .tabItem {
                Label("NR", systemImage: "antenna.radiowaves.left.and.right")
            }
            
            // MARK: - 2. Pozostałe zakładki
            
            KontaktView(backgroundImageName: backgroundImageName)
                .tabItem { Label("Kontakt", systemImage: "phone.fill") }
            
            ReklamaView(backgroundImageName: backgroundImageName)
                .tabItem { Label("Reklama", systemImage: "speaker.fill") }

            ONasView(backgroundImageName: backgroundImageName)
                .tabItem { Label("O Nas", systemImage: "info.circle.fill") }

            WiadomosciView(backgroundImageName: backgroundImageName)
                .tabItem { Label("Wiadomości", systemImage: "newspaper.fill") }
            
        }
        .tint(.white)
    }
}

#Preview {
    ContentView()
}
