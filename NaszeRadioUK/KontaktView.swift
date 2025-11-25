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

    // MARK: - POPRAWIONE LINKI (Deep Links)
    // WhatsApp: Bez zmian, działa dobrze
    private let whatsAppURL = URL(string: "https://wa.me/44777123456")!
    
    // Facebook: Często lepiej działa bez 'www' lub ze specyficznym ID, ale zostawiamy standardowy jeśli działał
    private let facebookURL = URL(string: "https://www.facebook.com/naszeradiouk")!
    
    // TikTok: Usunięcie 'www' często pomaga wymusić otwarcie aplikacji
    private let tiktokURL = URL(string: "https://tiktok.com/@naszeradiouk")!
    
    // Instagram: Dodanie '/_u/' wymusza otwarcie w aplikacji na iOS!
    private let instagramURL = URL(string: "https://instagram.com/_u/naszeradiouk")!
    
    var body: some View {
        ZStack {
            // TŁO
            Image(backgroundImageName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // MARK: - Warstwa TREŚCI
            VStack(spacing: 0) {
                
                // MARK: - NAGŁÓWEK
                VStack(spacing: 5) {
                    Text("Masz ciekawy temat?")
                        .font(.title2)
                    Text("Widzisz coś na drodze?")
                        .font(.title2)
                    Text("Napisz do nas:")
                        .font(.title3)
                        .fontWeight(.light)
                }
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.top, 80)

                
                // MARK: - PRZYCISK WHATSAPP
                Link(destination: whatsAppURL) {
                    Text("Wyślij wiadomość na WhatsApp")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.vertical, 15)
                        .frame(width: 300)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.green)
                                .scaleEffect(pulsate ? 1.05 : 1.0)
                        )
                }
                .padding(.top, 40)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                        pulsate.toggle()
                    }
                }
                
                // MARK: - LINKI DO SOCIAL MEDIÓW
                VStack(spacing: 40) {
                    LinkText(title: "Facebook", url: facebookURL)
                    LinkText(title: "TikTok", url: tiktokURL)
                    LinkText(title: "Instagram", url: instagramURL)
                }
                .padding(.top, 70)
                
                Spacer()
                
                // STOPKA
                Text("Nasze Radio UK © 2025")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)
            }
            .padding(.horizontal, 30)
            
            .toolbarColorScheme(.dark, for: .tabBar)
            
        } // Koniec ZStack
    }
}

// MARK: - Pomocniczy Widok dla Linków
struct LinkText: View {
    let title: String
    let url: URL
    
    var body: some View {
        Link(destination: url) {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    KontaktView(backgroundImageName: "HexagonBackground")
}
