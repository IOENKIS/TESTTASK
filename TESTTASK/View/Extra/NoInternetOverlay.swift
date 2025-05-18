//
//  NoInternetOverlay.swift
//  TESTTASK
//
//  Created by Ivan Kisilov on 18.05.2025.
//
import SwiftUI

struct NoInternetOverlay: View {
    let retry: () -> Void

    var body: some View {
        Color.customBackground.opacity(0.95).ignoresSafeArea()
            .overlay(
                VStack(spacing: 24) {
                    Image(.noInternet)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200)
                    Text("There is no internet connection")
                        .heading1()
                        .multilineTextAlignment(.center)
                    Button("Try again", action: retry)
                        .primaryButton()
                        .frame(width: 140)
                }
                .padding()
            )
    }
}
