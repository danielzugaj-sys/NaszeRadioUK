//
//  ONasView.swift
//  NaszeRadioUK
//
//  Created by user on 23/11/2025.
//

import SwiftUI

struct ONasView: View {
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
                Text("O NAS")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("Tutaj pojawi się historia stacji i misja.")
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
            }
        }
    }
}
