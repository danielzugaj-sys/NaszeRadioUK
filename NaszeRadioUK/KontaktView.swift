//
//  KontaktView.swift
//  NaszeRadioUK
//
//  Created by user on 23/11/2025.
//

import SwiftUI

struct KontaktView: View {
    
    let backgroundImageName: String
    
    @State private var pulsate = false

    // MARK: - Adresy do przekierowań
    private let whatsAppURL = URL(string: "https://wa.me/44777123456")!
    private let facebookURL = URL(string: "https://www.facebook.com/naszeradiouk/")!
    private let tiktokURL = URL(string: "https://www.tiktok.com/@naszeradio_uk?_r=1&_t=ZN-91hZNxiXpVm")!
    private let instagramURL = URL(string: "https://www.instagram.com/naszeradiowuk/?igsh=NHFtdm8ybno1dG0w#")!
    
    var body: some View {
        ZStack {
            // TŁO
            Image(backgroundImageName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // MARK: - Warstwa TREŚCI
            VStack(spacing: 0) { // Używamy spacing: 0 i kontrolujemy odstępy paddingiem
                
                // MARK: - NAGŁÓWEK (WYŚRODKOWANIE I ROZMIARY)
                VStack(spacing: 5) { // Mały spacing dla zbliżenia linii
                    Text("Masz ciekawy temat?")
                        .font(.largeTitle) // Rozmiar
                    Text("Widzisz coś na drodze?")
                        .font(.largeTitle) // Rozmiar
                    Text("Napisz do nas:")
                        .font(.title) // Rozmiar
                        .fontWeight(.light)
                }
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.top, 80) // Duży odstęp od góry

                
                // MARK: - PRZYCISK WHATSAPP (Szerokość i Animacja)
                // Używamy padding(top: 40) do oddzielenia od nagłówka
                Link(destination: whatsAppURL) {
                    Text("Wyślij wiadomość na WhatsApp")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.vertical, 20) // Dodatkowy pionowy padding dla wysokości
                        .frame(width: 300) // Stała, duża szerokość
                        .background(
                            RoundedRectangle(cornerRadius: 19)
                                .fill(Color.green)
                                .scaleEffect(pulsate ? 1.05 : 1.0)
                        )
                }
                .padding(.top, 40)
                
                // Aktywacja animacji pulsowania
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                        pulsate.toggle()
                    }
                }
                
                // MARK: - LINKI DO SOCIAL MEDIÓW (Większy rozmiar i odstępy)
                VStack(spacing: 40) { // Duży odstęp między linkami
                    LinkText(title: "Facebook", url: facebookURL)
                    LinkText(title: "TikTok", url: tiktokURL)
                    LinkText(title: "Instagram", url: instagramURL)
                }
                .padding(.top, 90) // Duży odstęp od guzika WhatsApp
                
                Spacer() // Pchnięcie stopki na dół
                
                // STOPKA
                Text("Nasze Radio UK © 2025")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 10) // Mały odstęp od dolnego paska
            }
            .padding(.horizontal, 30) // Utrzymujemy poziome marginesy
            
            // Ustawienie, by tło paska nawigacyjnego było czarne
            .toolbarColorScheme(.dark, for: .tabBar)
            
        } // Koniec ZStack
    }
}

// MARK: - Pomocniczy Widok dla Linków
// Poprawiona czcionka i usunięte podkreślenie (na screenie jest tylko pogrubienie)
struct LinkText: View {
    let title: String
    let url: URL
    
    var body: some View {
        Link(destination: url) {
            Text(title)
                .font(.largeTitle) // ⬅️ Zwiększona czcionka
                .fontWeight(.semibold)
            // .underline() // Usunięte podkreślenie, bo nie jest na screenie
                .foregroundColor(.white)
        }
    }
}
    #Preview {
        KontaktView(backgroundImageName: "HexagonBackground")
    }
