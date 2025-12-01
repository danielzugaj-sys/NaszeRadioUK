//
//  ONasView.swift
//  NaszeRadioUK
//
//  Created by user on 23/11/2025.
//

import SwiftUI

struct ONasView: View {
    let backgroundImageName: String
    private let websiteURL = URL(string: "https://www.naszeradio.uk")!
    private let privacyURL = URL(string: "https://naszeradio.uk/polityka-prywatnosci/")!
    
    var body: some View {
        ZStack {
            Image(backgroundImageName).resizable().scaledToFill().ignoresSafeArea()
            
            // Tu zostawiamy ScrollView, bo tekstu jest dużo, ale ograniczamy szerokość
            ScrollView {
                VStack(spacing: 0) {
                    Text("O NAS").font(.system(size: 40)).fontWeight(.heavy).foregroundColor(.white).padding(.top, 50).padding(.bottom, 30)
                    
                    Text("Radio stworzone z myślą o Polonii w każdym zakątku Wielkiej Brytanii. Bez względu na to, gdzie mieszkasz — jesteśmy z Tobą, aby dostarczać:")
                        .font(.title3).fontWeight(.medium).foregroundColor(.white).multilineTextAlignment(.center).padding(.horizontal, 20).padding(.bottom, 20)
                    
                    VStack(spacing: 10) {
                        Text("• aktualne informacje")
                        Text("• niezapomniane hity")
                        Text("• gramy Waszą muzykę")
                    }
                    .font(.title3).fontWeight(.bold).foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.4)).padding(.bottom, 20)
                    
                    Text("To radio tworzone przez ludzi z pasją — bo Twoje potrzeby są dla nas najważniejsze.")
                        .font(.title3).fontWeight(.medium).foregroundColor(.white).multilineTextAlignment(.center).padding(.horizontal, 20).padding(.bottom, 30)
                    
                    Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.7)).padding(.horizontal, 60).padding(.bottom, 40)
                    
                    VStack(spacing: 20) {
                        Link(destination: websiteURL) {
                            HStack {
                                Image(systemName: "globe").font(.title2).foregroundColor(.blue)
                                Text("Strona Internetowa").font(.headline).fontWeight(.bold).foregroundColor(.white)
                            }
                            .padding().frame(maxWidth: .infinity).background(Color.black.opacity(0.6)).cornerRadius(10)
                        }
                        Link(destination: privacyURL) {
                            HStack {
                                Image(systemName: "doc.text.fill").font(.title2).foregroundColor(Color(red: 0.8, green: 0.7, blue: 0.5))
                                Text("Polityka Prywatności").font(.headline).fontWeight(.bold).foregroundColor(.white)
                            }
                            .padding().frame(maxWidth: .infinity).background(Color.black.opacity(0.6)).cornerRadius(10)
                        }
                    }.padding(.horizontal, 40)
                    
                    Spacer()
                    VStack(spacing: 5) {
                        Text("© 2025 Daniel Żugaj — Wszystkie prawa zastrzeżone")
                        Text("Nasze Radio UK © 2025")
                    }.font(.caption).foregroundColor(.gray).padding(.top, 50).padding(.bottom, 20)
                }
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview {
    ONasView(backgroundImageName: "HexagonBackground")
}
