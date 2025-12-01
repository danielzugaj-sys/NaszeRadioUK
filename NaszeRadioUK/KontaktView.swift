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

    private let whatsAppURL = URL(string: "https://wa.me/4407300191211")!
    private let facebookAppURL = "fb://profile/100083266690757"
    private let facebookWebURL = "https://www.facebook.com/naszeradiouk/"
    private let tiktokAppURL = "snssdk1232://user/profile/naszeradio_uk"
    private let tiktokWebURL = "https://www.tiktok.com/@naszeradio_uk"
    private let instagramAppURL = "instagram://user?username=naszeradiowuk"
    private let instagramWebURL = "https://www.instagram.com/naszeradiowuk/"
    
    var body: some View {
        ZStack {
            Image(backgroundImageName).resizable().scaledToFill().ignoresSafeArea()
            
            // UKŁAD IDENTYCZNY JAK W REKLAMIE
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 0) {
                    Text("Masz ciekawy temat?")
                        .font(.title2).fontWeight(.medium).foregroundColor(.white).padding(.bottom, 5)
                    
                    Text("Widzisz coś na drodze?")
                        .font(.title2).fontWeight(.medium).foregroundColor(.white).padding(.bottom, 5)
                    
                    Text("Napisz do nas:")
                        .font(.title2).fontWeight(.light).foregroundColor(.white).padding(.bottom, 40)

                    Link(destination: whatsAppURL) {
                        Text("Wyślij wiadomość na WhatsApp")
                            .font(.headline).fontWeight(.bold).foregroundColor(.black)
                            .padding(.vertical, 15)
                            .frame(width: 300)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.green).scaleEffect(pulsate ? 1.05 : 1.0))
                    }
                    .padding(.bottom, 40)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) { pulsate.toggle() }
                    }
                    
                    VStack(spacing: 30) {
                        SmartLinkButton(title: "Facebook", appLink: facebookAppURL, webLink: facebookWebURL)
                        SmartLinkButton(title: "TikTok", appLink: tiktokAppURL, webLink: tiktokWebURL)
                        SmartLinkButton(title: "Instagram", appLink: instagramAppURL, webLink: instagramWebURL)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                Text("Nasze Radio UK © 2025")
                    .font(.caption).foregroundColor(.gray).padding(.bottom, 20)
            }
            .frame(maxWidth: 600)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct SmartLinkButton: View {
    let title: String; let appLink: String; let webLink: String
    var body: some View {
        Button(action: { openSmartLink() }) {
            Text(title).font(.largeTitle).fontWeight(.semibold).foregroundColor(.white)
        }
    }
    func openSmartLink() {
        if let appURL = URL(string: appLink) {
            UIApplication.shared.open(appURL) { success in
                if !success { if let webURL = URL(string: webLink) { UIApplication.shared.open(webURL) } }
            }
        }
    }
}

#Preview {
    KontaktView(backgroundImageName: "HexagonBackground")
}
