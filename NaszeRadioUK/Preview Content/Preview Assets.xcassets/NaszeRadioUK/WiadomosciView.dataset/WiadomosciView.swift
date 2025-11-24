//
//  WiadomosciView.swift
//  NaszeRadioUK
//
//  Created by user on 23/11/2025.
//

import SwiftUI

struct WiadomosciView: View {
    let backgroundImageName: String
    
    var body: some View {
        ZStack {
            // TŁO Z SZEŚCIOKĄTAMI
            Image(backgroundImageName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // TREŚĆ (Placeholdery)
            VStack {
                Spacer()
                Text("WIADOMOŚCI")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("Tutaj będą najnowsze informacje i artykuły.")
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
            }
        }
    }
}
