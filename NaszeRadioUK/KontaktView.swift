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

    // MARK: - KONFIGURACJA LINKÓW
    
    // WhatsApp
    private let whatsAppURL = URL(string: "https://wa.me/44777123456")!
    
    // FACEBOOK: NOWA, LEPSZA METODA
    // Używamy formatu, który mówi apce FB: "Otwórz ten adres WWW u siebie"
    private let facebookAppURL = "fb://facewebmodal/f?href=https://www.facebook.com/naszeradiouk"
    private let facebookWebURL = "https://www.facebook.com/naszeradiouk/"
    
    // TIKTOK
    private let tiktokAppURL = "snssdk1232://user/profile/naszeradio_uk"
    private let tiktokWebURL = "https://www.tiktok.com/@naszeradio_uk"
    
    // INSTAGRAM
    private let instagramAppURL = "instagram://user?username=naszeradiowuk"
    private let instagramWebURL = "https://www.instagram.com/naszeradiowuk/"
    
    var body: some View {
        ZStack {
            // TŁO
            Image(backgroundImageName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // MARK: - Warstwa TREŚCI
            VStack(spacing: 0) {
                
                // NAGŁÓWEK
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

                
                // PRZYCISK WHATSAPP
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
                
                // MARK: - LINKI DO SOCIAL MEDIÓW (SMART BUTTONS)
                VStack(spacing: 40) {
                    // Facebook
                    SmartLinkButton(title: "Facebook", appLink: facebookAppURL, webLink: facebookWebURL)
                    
                    // TikTok
                    SmartLinkButton(title: "TikTok", appLink: tiktokAppURL, webLink: tiktokWebURL)
                    
                    // Instagram
                    SmartLinkButton(title: "Instagram", appLink: instagramAppURL, webLink: instagramWebURL)
                }
                .padding(.top, 70)
                
                Spacer()
                
                // STOPKA
                Text("Nasze Radio UK © 2025")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 1)
            }
            .padding(.horizontal, 30)
            .toolbarColorScheme(.dark, for: .tabBar)
            
        } // Koniec ZStack
    }
}

// MARK: - INTELIGENTNY PRZYCISK (Smart Button)
struct SmartLinkButton: View {
    let title: String
    let appLink: String
    let webLink: String
    
    var body: some View {
        Button(action: {
            openSmartLink()
        }) {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
    }
    
    func openSmartLink() {
        // 1. Próbujemy otworzyć link aplikacji
        if let appURL = URL(string: appLink) {
            UIApplication.shared.open(appURL) { success in
                // Jeśli się NIE uda (success jest false), otwieramy przeglądarkę
                if !success {
                    if let webURL = URL(string: webLink) {
                        UIApplication.shared.open(webURL)
                    }
                }
            }
        } else {
            // Jeśli link aplikacji jest błędny, od razu otwieramy WWW
            if let webURL = URL(string: webLink) {
                UIApplication.shared.open(webURL)
            }
        }
    }
}

#Preview {
    KontaktView(backgroundImageName: "HexagonBackground")
}
