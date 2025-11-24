import SwiftUI

struct ContentView: View {
    
    // Inicjalizacja silnika radiowego
    @StateObject var radioPlayer = RadioPlayer()

    // Nazwy plików graficznych z Assets.xcassets
    let backgroundImageName = "HexagonBackground"
    let mainLogoName = "MainLogo"
    
    var body: some View {
        // TabView tworzy dolny pasek nawigacyjny
        TabView {
            // MARK: - 1. Główny Ekran Radiowy (NR)
            ZStack {
                // 1. TŁO
                Image(backgroundImageName)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                // 2. GŁÓWNA ZAWARTOŚĆ
                VStack {
                    // Logo Główne
                    Image(mainLogoName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 300)
                        .padding(.top, 40)
                        .padding(.bottom, 40)
                    
                    Spacer()
                    
                    // INFORMACJA O PIOSENCE
                    Text(radioPlayer.currentTrack)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // PRZYCISKI PLAY / STOP
                    HStack(spacing: 50) {
                        // Poprawna logika PLAY / PAUZA
                        Button(action: {
                            if radioPlayer.isPlaying {
                                radioPlayer.pause()
                            } else {
                                radioPlayer.play()
                            }
                        }) {
                            Image(systemName: radioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 85))
                                .foregroundColor(Color.white)
                        }
                        
                        // Przycisk STOP
                        Button(action: {
                            radioPlayer.stop()
                        }) {
                            Image(systemName: "stop.circle.fill")
                                .font(.system(size: 85))
                                .foregroundColor(Color.white)
                        }
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 100)
                    
                    Spacer()
                    
                    // Stopka
                    Text("Nasze Radio UK © 2025")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.bottom, 5)
                }
            } // Koniec ZStack
            
            // Konfiguracja zakładki radiowej (POPRYWNE WYWOŁANIE LABEL)
            .tabItem {
                Label("NR", systemImage: "antenna.radiowaves.left.and.right")
            }
            
            // MARK: - 2. Pozostałe zakładki (Zintegrowane Widoki)
            
            // KONTAKT
            KontaktView(backgroundImageName: backgroundImageName)
                .tabItem { Label("Kontakt", systemImage: "phone.fill") } // POPRAWNE
            
            // REKLAMA
            ReklamaView(backgroundImageName: backgroundImageName)
                .tabItem { Label("Reklama", systemImage: "speaker.fill") } // POPRAWNE

            // O NAS
            ONasView(backgroundImageName: backgroundImageName)
                .tabItem { Label("O Nas", systemImage: "info.circle.fill") } // POPRAWNE

            // WIADOMOŚCI
            WiadomosciView(backgroundImageName: backgroundImageName)
                .tabItem { Label("Wiadomości", systemImage: "newspaper.fill") } // POPRAWNE
            
        } // Koniec TabView
        
        // Ustawienie stylów dla dolnego paska
        .tint(.white)
        .onAppear {
             UITabBar.appearance().barTintColor = .black
             UITabBar.appearance().isTranslucent = false
         }
    }
}
