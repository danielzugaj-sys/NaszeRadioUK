import SwiftUI

struct ContentView: View {
    
    @StateObject var radioPlayer = RadioPlayer()
    
    // Zmienna do animacji pulsowania napisu
    @State private var isPulsing = false

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

                // GŁÓWNY KONTENER
                VStack(spacing: 0) {
                   
                    // 1. GÓRNY SPACER
                    Spacer()
                   
                    // 2. TREŚĆ WŁAŚCIWA (Logo + Player)
                    VStack(spacing: 0) {
                        // Logo
                        Image(mainLogoName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 300)
                            .padding(.bottom, 30)
                       
                        // Tytuł
                        Text(radioPlayer.currentTrack)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.bottom, 40)
                            .animation(.default, value: radioPlayer.currentTrack) // Ładna animacja zmiany tekstu
                       
                        // --- ZMIANA: INTELIGENTNY PRZYCISK STARTU ---
                        ZStack {
                            
                            // 1. STAN BŁĘDU (BRAK INTERNETU PO 2 MINUTACH)
                            if let error = radioPlayer.connectionError {
                                VStack(spacing: 15) {
                                    Text(error)
                                        .font(.headline)
                                        .foregroundColor(.red)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                    
                                    // Przycisk "Spróbuj ponownie" (wygląda jak Play)
                                    Button(action: {
                                        radioPlayer.play()
                                    }) {
                                        Image(systemName: "arrow.clockwise.circle.fill")
                                            .font(.system(size: 80))
                                            .foregroundColor(.white)
                                            .shadow(radius: 10)
                                    }
                                }
                            }
                            
                            // 2. STAN ŁADOWANIA (KRĘCĄCE KÓŁKO + PULSUJĄCY NAPIS)
                            else if radioPlayer.isLoading {
                                VStack(spacing: 15) {
                                    Text("TRWA POŁĄCZENIE...")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .opacity(isPulsing ? 1.0 : 0.3) // Animacja przezroczystości
                                        .onAppear {
                                            withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                                                isPulsing = true
                                            }
                                        }
                                    
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(2.5) // Powiększone kółko
                                }
                                .frame(height: 100) // Rezerwujemy tyle samo miejsca co przycisk, żeby nie skakało
                            }
                            
                            // 3. STAN NORMALNY (PLAY / PAUSE)
                            else {
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
                                .transition(.scale) // Animacja pojawiania się przycisku
                            }
                        }
                        .padding(.bottom, 40)
                        // ---------------------------------------------
                       
                        // Suwak Głośności
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
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
