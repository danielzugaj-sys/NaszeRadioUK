//
//  ReklamaView.swift
//  NaszeRadioUK
//
//  Created by user on 23/11/2025.
//

import SwiftUI

struct ReklamaView: View {
    let backgroundImageName: String
    private let emailReklama = URL(string: "mailto:info@naszeradio.uk")!
    private let telefonReklama = URL(string: "tel:+4407300300208")!
    private let numerTekstowy = "+44 0730 0300 208"

    var body: some View {
        ZStack {
            Image(backgroundImageName).resizable().scaledToFill().ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 0) {
                    Text("Organizujesz event?").font(.title2).fontWeight(.medium).foregroundColor(.white).padding(.bottom, 5)
                    Text("Szukasz nagłośnienia?").font(.title2).fontWeight(.medium).foregroundColor(.white).padding(.bottom, 5)
                    Text("Potrzebujesz wsparcia medialnego?").font(.title2).fontWeight(.medium).foregroundColor(.white).multilineTextAlignment(.center).padding(.bottom, 40)
                    
                    Text("Skorzystaj z reklamy w").font(.title2).fontWeight(.regular).foregroundColor(.white).padding(.bottom, 5)
                    Text("NASZYM Radiu UK").font(.largeTitle).fontWeight(.heavy).foregroundColor(.white).multilineTextAlignment(.center).padding(.bottom, 40)

                    Link(destination: telefonReklama) {
                        Text(numerTekstowy)
                            .font(.system(size: 30)).fontWeight(.heavy)
                            .foregroundColor(Color(red: 0.5, green: 0.8, blue: 1.0))
                    }.padding(.bottom, 25)
                    
                    Link(destination: emailReklama) {
                        HStack(spacing: 10) {
                            Image(systemName: "envelope.fill").font(.title)
                            Text("info@naszeradio.uk").font(.title3).fontWeight(.bold)
                        }
                        .foregroundColor(.black).padding().frame(maxWidth: 320).background(Color.yellow).cornerRadius(10)
                    }.padding(.bottom, 25)
                    
                    HStack(spacing: 5) {
                        Text("Zadzwoń lub napisz – dopasujemy ofertę").font(.subheadline).foregroundColor(.white)
                        Image(systemName: "megaphone.fill").foregroundColor(.white)
                    }
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

#Preview {
    ReklamaView(backgroundImageName: "HexagonBackground")
}
