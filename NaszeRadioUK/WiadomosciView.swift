//
//  WiadomosciView.swift
//  NaszeRadioUK
//
//  Created by user on 23/11/2025.
//

import SwiftUI

struct WiadomosciView: View {
    let backgroundImageName: String
    
    // Linki do kategorii
    private let newsURL = URL(string: "https://naszeradio.uk/wiadomosci-2/")!
    private let sportURL = URL(string: "https://naszeradio.uk/sport/")!
    private let cultureURL = URL(string: "https://naszeradio.uk/kultura/")!
    private let weatherURL = URL(string: "https://www.metoffice.gov.uk/")!
    private let polandURL = URL(string: "https://www.pap.pl/")!
    
    var body: some View {
        ZStack {
            // TŁO
            Image(backgroundImageName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // TREŚĆ
            VStack(spacing: 0) {
                
                // 1. NAGŁÓWEK
                Text("Wybierz coś dla siebie")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 140)
                    .padding(.bottom, 60)
                
                // 2. LISTA KATEGORII
                VStack(spacing: 30) {
                    
                    CategoryLink(title: "Aktualności", iconName: "newspaper.fill", url: newsURL)
                    
                    CategoryLink(title: "Sport", iconName: "soccerball", url: sportURL)
                    
                    CategoryLink(title: "Kultura", iconName: "theatermasks.fill", url: cultureURL)
                    
                    CategoryLink(title: "Pogoda", iconName: "cloud.sun.fill", url: weatherURL)
                    
                    CategoryLink(title: "Polska", iconName: "flag.fill", url: polandURL)
                    
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // 3. STOPKA
                Text("Nasze Radio UK © 2025")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
            }
        }
    }
}

// MARK: - O TO CHODZIŁO! TEGO BRAKOWAŁO:
// Pomocniczy Widok Pojedynczego Linku
struct CategoryLink: View {
    let title: String
    let iconName: String
    let url: URL
    
    var body: some View {
        Link(destination: url) {
            HStack(spacing: 20) {
                // Ikona
                Image(systemName: iconName)
                    .font(.largeTitle)
                    .frame(width: 40)
                
                // Tekst
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            .foregroundColor(.white)
        }
    }
}

#Preview {
    WiadomosciView(backgroundImageName: "HexagonBackground")
}
