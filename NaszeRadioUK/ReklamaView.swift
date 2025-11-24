//
//  ReklamaView.swift
//  NaszeRadioUK
//
//  Created by user on 23/11/2025.
//

import SwiftUI

struct ReklamaView: View {
    let backgroundImageName: String

    // Adresy kontaktowe
    private let emailReklama = URL(string: "mailto:info@naszeradio.uk")!
    private let telefonReklama = URL(string: "tel:+4407300300208")!
    private let numerTekstowy = "+44 0730 0300 208"

    var body: some View {
        ZStack {
            // TŁO Z SZEŚCIOKĄTAMI
            Image(backgroundImageName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // GŁÓWNY KONTENER
            VStack(spacing: 0) {
                
                // Spacer spychający zawartość na środek
                Spacer()
                
                // GŁÓWNY BLOK TEKSTU I PRZYCISKÓW
                VStack(spacing: 0) {
                    
                    // MARK: - LINIA 1
                    Text("Organizujesz event?")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 5)
                    
                    Text("Szukasz nagłośnienia?")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 5)
                    
                    // MARK: - LINIA 2
                    Text("Potrzebujesz wsparcia medialnego?")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    
                    // MARK: - LINIA 3
                    Text("Skorzystaj z reklamy w")
                        .font(.title2)
                        .fontWeight(.regular)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 5)
                    
                    // MARK: - LINIA 4 (NASZYM Radiu UK)
                    Text("NASZYM Radiu UK")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 40)

                    
                    // MARK: - PRZYCISK TELEFON
                    Link(destination: telefonReklama) {
                        Text(numerTekstowy)
                            .font(.system(size: 30))
                            .fontWeight(.heavy)
                            .foregroundColor(Color(red: 0.5, green: 0.8, blue: 1.0)) // Jasny niebieski
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 25)
                    
                    // MARK: - ŻÓŁTY PRZYCISK EMAIL (POWIĘKSZONY TEKST I IKONA)
                    Link(destination: emailReklama) {
                        HStack(spacing: 10) {
                            // Ikona koperty - powiększona
                            Image(systemName: "envelope.fill")
                                .font(.title) // Duży rozmiar ikony
                            
                            // Adres email - powiększony
                            Text("info@naszeradio.uk")
                                .font(.title3) // Duża, czytelna czcionka
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: 320) // Nieco szerszy przycisk, by pomieścić większy tekst
                        .background(Color.yellow)
                        .cornerRadius(10)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 25)
                    
                    // MARK: - PODPOWIEDŹ
                    HStack(spacing: 5) {
                        Text("Zadzwoń lub napisz – dopasujemy ofertę")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Image(systemName: "megaphone.fill")
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)
                }
                
                // Spacer spychający zawartość na środek (i stopkę na dół)
                Spacer()
                
                // MARK: - STOPKA
                Text("Nasze Radio UK © 2025")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
                    .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ReklamaView(backgroundImageName: "HexagonBackground")
}
