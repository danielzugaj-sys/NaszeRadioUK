import SwiftUI

struct ContentView: View {
    
    @StateObject var radioPlayer = RadioPlayer()

    let backgroundImageName = "HexagonBackground"
    let mainLogoName = "MainLogo"
    
    var body: some View {
        TabView {
            // MARK: - 1. Główny Ekran Radiowy
            ZStack {
                // WARSTWA 1: TŁO (Rozciągnięte na maksa)
                // Używamy GeometryReader tylko do tła, żeby mieć pewność, że wypełni wszystko
                GeometryReader { geo in
                    Image(backgroundImageName)
                        .resizable()
                        .scaledToFill() // Kluczowe: Wypełnia cały ekran, przycinając nadmiar
                        .frame(width: geo.size.width, height: geo.size.height)
                        .ignoresSafeArea()
                }

                // WARSTWA 2: TREŚĆ (Bezpieczna, na środku)
                VStack {
                    // Logo Główne
                    Image(mainLogoName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 300)
                        .padding(.top, 60)
                        .padding(.bottom, 20)
                    
                    Spacer()
                    
                    // Tytuł
                    Text(radioPlayer.currentTrack)
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    
                    // Play
                    Button(action: {
                        if radioPlayer.isPlaying {
                            radioPlayer.pause()
                        } else {
                            radioPlayer.play()
                        }
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
                            Slider(value: $radioPlayer.volume, in: 0...1)
                                .accentColor(.white)
                            Image(systemName: "speaker.wave.3.fill").foregroundColor(.white)
                        }
                        .padding(.horizontal, 40)
                    }
                    .padding(.bottom, 60)
                    
                    Spacer()
                    
                    // Stopka
                    Text("Nasze Radio UK © 2025")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                }
                .frame(maxWidth: 600) // Trzyma treść w ryzach na iPadzie
            }
            .tabItem {
                Label("NR", systemImage: "antenna.radiowaves.left.and.right")
            }
            
            // MARK: - 2. Pozostałe zakładki
            // (One używają swoich plików, więc tam też tło musi być tak zrobione,
            // ale sprawdźmy najpierw czy strona główna działa)
            
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
        .onAppear {
             UITabBar.appearance().barTintColor = .black
             UITabBar.appearance().isTranslucent = false
         }
    }
}

#Preview {
    ContentView()
}
