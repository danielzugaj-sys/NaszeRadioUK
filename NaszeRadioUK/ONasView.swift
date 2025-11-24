//
//  ONasView.swift
//  NaszeRadioUK
//
//  Created by user on 23/11/2025.
//

import SwiftUI

struct ONasView: View {
    let backgroundImageName: String
    
    // Linki
    private let websiteURL = URL(string: "https://www.naszeradio.uk")!
    private let privacyURL = URL(string: "https://naszeradio.uk/polityka-prywatnosci/")!
    
    var body: some View {
        ZStack {
            // TŁO
            Image(backgroundImageName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // TREŚĆ
            ScrollView {
                VStack(spacing: 0) {
                    
                    // 1. NAGŁÓWEK "O NAS"
                    Text("O NAS")
                        .font(.system(size: 40))
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                        .padding(.top, 50)
                        .padding(.bottom, 30)
                    
                    // 2. PIERWSZY BLOK TEKSTU
                    Text("Radio stworzone z myślą o Polonii w każdym zakątku Wielkiej Brytanii. Bez względu na to, gdzie mieszkasz - jesteśmy z Tobą, aby dostarczać:")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // 3. PUNKTY (Złoty Kolor)
                    VStack(spacing: 10) {
                        Text("• aktualne informacje")
                        Text("• niezapomniane hity")
                        Text("• gramy Waszą muzykę")
                    }
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.4))
                    .padding(.bottom, 20)
                    
                    // 4. DRUGI BLOK TEKSTU
                    Text("To radio tworzone przez ludzi z pasją - bo Twoje potrzeby są dla nas najważniejsze.")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // 5. LINIA ODZIELAJĄCA
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.7))
                        .padding(.horizontal, 60)
                        .padding(.bottom, 40)
                    
                    // 6. PRZYCISKI
                    VStack(spacing: 20) {
                        
                        // Przycisk Strona Internetowa
                        Link(destination: websiteURL) {
                            HStack {
                                // Zmieniono na podstawową ikonę 'globe', działa na każdym iOS
                                Image(systemName: "globe")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                
                                Text("Strona Internetowa")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.black.opacity(0.4))
                            .cornerRadius(10)
                        }
                        
                        // Przycisk Polityka Prywatności
                        Link(destination: privacyURL) {
                            HStack {
                                // Zmieniono na podstawową ikonę 'doc.text.fill'
                                Image(systemName: "doc.text.fill")
                                    .font(.title2)
                                    .foregroundColor(Color(red: 0.8, green: 0.7, blue: 0.5))
                                
                                Text("Polityka Prywatności")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.black.opacity(0.4))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                    
                    // 7. STOPKA
                    VStack(spacing: 5) {
                        Text("© 2025 Daniel Żugaj — Wszystkie prawa zastrzeżone")
                        Text("Nasze Radio UK © 2025")
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 50)
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

#Preview {
    ONasView(backgroundImageName: "HexagonBackground")
}
