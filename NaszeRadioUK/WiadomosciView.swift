//
//  WiadomosciView.swift
//  NaszeRadioUK
//
//  Created by user on 23/11/2025.
//

import SwiftUI

struct WiadomosciView: View {
    let backgroundImageName: String
    
    private let newsURL = URL(string: "https://naszeradio.uk/wiadomosci-2/")!
    private let sportURL = URL(string: "https://naszeradio.uk/sport/")!
    private let cultureURL = URL(string: "https://naszeradio.uk/kultura/")!
    private let weatherURL = URL(string: "https://www.metoffice.gov.uk/")!
    private let polandURL = URL(string: "https://www.pap.pl/")!
    
    var body: some View {
        ZStack {
            Image(backgroundImageName).resizable().scaledToFill().ignoresSafeArea()
            
            VStack(spacing: 0) {
                Text("Wybierz coś dla siebie").font(.largeTitle).fontWeight(.bold).foregroundColor(.white).multilineTextAlignment(.center).padding(.top, 60).padding(.bottom, 50)
                
                VStack(spacing: 35) {
                    CategoryLink(title: "Aktualności", iconName: "newspaper.fill", url: newsURL)
                    CategoryLink(title: "Sport", iconName: "soccerball", url: sportURL)
                    CategoryLink(title: "Kultura", iconName: "theatermasks.fill", url: cultureURL)
                    CategoryLink(title: "Pogoda", iconName: "cloud.sun.fill", url: weatherURL)
                    CategoryLink(title: "Polska", iconName: "flag.fill", url: polandURL)
                }
                .padding(.horizontal, 20)
                
                Spacer()
                Text("Nasze Radio UK © 2025").font(.caption).foregroundColor(.gray).padding(.bottom, 20)
            }
            .frame(maxWidth: 600)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct CategoryLink: View {
    let title: String; let iconName: String; let url: URL
    var body: some View {
        Link(destination: url) {
            HStack(spacing: 20) {
                Image(systemName: iconName).font(.largeTitle).frame(width: 40)
                Text(title).font(.largeTitle).fontWeight(.bold)
            }.foregroundColor(.white)
        }
    }
}

#Preview {
    WiadomosciView(backgroundImageName: "HexagonBackground")
}
