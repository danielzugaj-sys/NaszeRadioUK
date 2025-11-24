//
//  ReklamaView.swift
//  NaszeRadioUK
//
//  Created by user on 23/11/2025.
//

import SwiftUI

struct ReklamaView: View {
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
                Text("REKLAMA")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("Tutaj będą informacje o możliwościach reklamy.")
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
            }
        }
    }
}
